<?php
declare(strict_types=1);

final class Outbox
{
    public const MAX_ATTEMPTS = 5;
    public const SUBJECTS = [
        'email.verify' => 'Xác minh địa chỉ email OurBudget',
        'auth.registered' => 'Đăng ký OurBudget thành công',
        'auth.login' => 'Đăng nhập OurBudget thành công',
        'transaction.created' => 'Đã ghi nhận thu/chi',
        'transaction.updated' => 'Đã cập nhật thu/chi',
        'transaction.deleted' => 'Đã xóa thu/chi',
    ];

    // Called by a domain service inside the same transaction as its business write.
    public static function enqueue(PDO $pdo, int $userId, string $eventId, string $event, array $payload = []): bool
    {
        if (!$pdo->inTransaction()) {
            throw new LogicException('Outbox requires an active business transaction');
        }
        if (!isset(self::SUBJECTS[$event]) || !preg_match('/^[a-zA-Z0-9:._-]{1,128}$/D', $eventId)) {
            throw new InvalidArgumentException('Invalid outbox event');
        }
        $query = $pdo->prepare('SELECT users_email, users_is_active, email_verified_at FROM users WHERE users_id = ? FOR UPDATE');
        $query->execute([$userId]);
        $user = $query->fetch();
        if (!$user || !$user['users_is_active']) {
            throw new InvalidArgumentException('Inactive or missing user');
        }
        if ($event !== 'email.verify' && $user['email_verified_at'] === null) {
            return false;
        }
        $entry = ['users_id' => $userId, 'recipient' => $user['users_email'], 'event_type' => $event, 'payload' => json_encode($payload, JSON_THROW_ON_ERROR)];
        if ($event === 'email.verify' && !self::recipientValid($pdo, $entry)) {
            throw new InvalidArgumentException('Verification is not pending for the current email');
        }
        $query = $pdo->prepare('INSERT INTO email_outbox (event_id, users_id, event_type, recipient, payload) VALUES (?, ?, ?, ?, ?)');
        $query->execute([$eventId, $userId, $event, $entry['recipient'], $entry['payload']]);
        return true;
    }

    public static function claim(PDO $pdo): ?array
    {
        $pdo->beginTransaction();
        try {
            $row = $pdo->query("SELECT * FROM email_outbox WHERE
                (status = 'pending' AND next_attempt_at <= NOW()) OR
                (status = 'processing' AND locked_until <= NOW())
                ORDER BY outbox_id LIMIT 1 FOR UPDATE SKIP LOCKED")->fetch();
            if (!$row) {
                $pdo->commit();
                return null;
            }
            if ((int) $row['attempts'] >= self::MAX_ATTEMPTS) {
                $pdo->prepare("UPDATE email_outbox SET status = 'failed', claim_token = NULL, locked_until = NULL, last_error = 'attempts_exhausted' WHERE outbox_id = ?")
                    ->execute([$row['outbox_id']]);
                $pdo->commit();
                return ['exhausted' => true];
            }
            $row['claim_token'] = bin2hex(random_bytes(16));
            $row['attempts'] = (int) $row['attempts'] + 1;
            $pdo->prepare("UPDATE email_outbox SET status = 'processing', attempts = ?, claim_token = ?, locked_until = DATE_ADD(NOW(), INTERVAL 120 SECOND) WHERE outbox_id = ?")
                ->execute([$row['attempts'], $row['claim_token'], $row['outbox_id']]);
            $pdo->commit();
            return $row;
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            throw $e;
        }
    }

    public static function recipientValid(PDO $pdo, array $row): bool
    {
        $query = $pdo->prepare('SELECT users_email, users_is_active, email_verified_at FROM users WHERE users_id = ?');
        $query->execute([$row['users_id']]);
        $user = $query->fetch();
        if (!$user || !$user['users_is_active'] || $user['users_email'] !== $row['recipient']) {
            return false;
        }
        if ($row['event_type'] !== 'email.verify') {
            return $user['email_verified_at'] !== null;
        }
        $payload = json_decode($row['payload'], true, flags: JSON_THROW_ON_ERROR);
        $query = $pdo->prepare('SELECT 1 FROM email_verifications WHERE verification_id = ? AND users_id = ? AND email = ? AND used_at IS NULL AND expires_at > NOW()');
        $query->execute([$payload['verification_id'] ?? 0, $row['users_id'], $row['recipient']]);
        return (bool) $query->fetchColumn();
    }

    public static function finish(PDO $pdo, array $row, string $status, ?string $error = null): void
    {
        if (!in_array($status, ['sent', 'pending', 'failed', 'cancelled'], true)) {
            throw new InvalidArgumentException('Invalid completion state');
        }
        $delay = min(3600, 30 * (2 ** ((int) $row['attempts'] - 1)));
        $query = $pdo->prepare("UPDATE email_outbox SET status = ?, last_error = ?, claim_token = NULL,
            locked_until = NULL, sent_at = IF(? = 'sent', NOW(), NULL),
            next_attempt_at = DATE_ADD(NOW(), INTERVAL ? SECOND)
            WHERE outbox_id = ? AND status = 'processing' AND claim_token = ?");
        $query->execute([$status, $error, $status, $delay, $row['outbox_id'], $row['claim_token']]);
    }

    public static function workOne(PDO $pdo, callable $deliver): bool
    {
        $row = self::claim($pdo);
        if ($row === null) {
            return false;
        }
        if (isset($row['exhausted'])) {
            return true;
        }
        if (!self::recipientValid($pdo, $row)) {
            self::finish($pdo, $row, 'cancelled', 'recipient_changed_or_unverified');
            return true;
        }
        try {
            $deliver($row);
            self::finish($pdo, $row, 'sent');
        } catch (Throwable) {
            self::finish($pdo, $row, $row['attempts'] >= self::MAX_ATTEMPTS ? 'failed' : 'pending', 'delivery_failed');
        }
        return true;
    }
}
