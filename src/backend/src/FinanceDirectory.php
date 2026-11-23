<?php
declare(strict_types=1);

final class FinanceDirectory
{
    public function __construct(private PDO $pdo) {}

    public function wallets(int $userId, array $query): array
    {
        return $this->page(
            'SELECT w.wallets_id::text AS id, w.wallets_name AS name,
                    w.walletcates_id::text AS category_id, c.walletcates_name AS category_name,
                    w.wallets_opening_balance::text AS opening_balance,
                    w.wallets_current_balance::text AS current_balance,
                    w.wallets_priority AS priority, (w.wallets_is_active = 1) AS is_active
             FROM public.wallets w
             JOIN public.wallet_categories c USING (walletcates_id)
             WHERE w.users_id = :owner
             ORDER BY w.wallets_priority, w.wallets_id',
            ['owner' => $userId],
            $query
        );
    }

    private function categoryPrefix(mixed $type): string
    {
        return match ($type) {
            'income' => 'income',
            'expense' => 'outcome',
            default => throw new ApiError(422, 'validation_failed', 'Chọn loại danh mục thu hoặc chi.'),
        };
    }

    public function categories(int $userId, array $query): array
    {
        $type = $query['type'] ?? null;
        $prefix = $this->categoryPrefix($type);
        return $this->page(
            "SELECT {$prefix}_id::text AS id, {$prefix}_name AS name, {$prefix}_icon AS icon,
                    CAST(:type AS text) AS type, (users_id IS NULL) AS is_system
             FROM public.{$prefix}_categories
             WHERE users_id IS NULL OR users_id = :owner ORDER BY {$prefix}_id",
            ['type' => $type, 'owner' => $userId],
            $query
        );
    }

    public function walletTypes(): array
    {
        return ['items' => $this->pdo->query(
            'SELECT walletcates_id::text AS id, walletcates_name AS name
             FROM public.wallet_categories ORDER BY walletcates_id'
        )->fetchAll(PDO::FETCH_ASSOC)];
    }

    public function createWallet(int $userId, array $input): array
    {
        $name = $this->name($input, 100);
        $type = $input['category_id'] ?? null;
        $balance = $input['opening_balance'] ?? null;
        if (!is_string($type) || !preg_match('/^[1-9][0-9]{0,18}$/D', $type)
            || filter_var($type, FILTER_VALIDATE_INT) === false
            || !is_string($balance) || !preg_match('/^-?(0|[1-9][0-9]{0,18})$/D', $balance)
            || filter_var($balance, FILTER_VALIDATE_INT) === false) {
            throw new ApiError(422, 'validation_failed', 'Loại ví hoặc số dư đầu kỳ không hợp lệ.');
        }
        $this->pdo->beginTransaction();
        try {
            // Serialize priority assignment, including when the account has no wallets.
            $lock = $this->pdo->prepare('SELECT users_id FROM public.users WHERE users_id = ? FOR NO KEY UPDATE');
            $lock->execute([$userId]);
            $category = $this->pdo->prepare('SELECT 1 FROM public.wallet_categories WHERE walletcates_id = ? FOR KEY SHARE');
            $category->execute([$type]);
            if (!$category->fetchColumn()) {
                throw new ApiError(422, 'validation_failed', 'Loại ví không tồn tại.');
            }
            $next = $this->pdo->prepare(
                'SELECT COALESCE(MAX(wallets_priority) + 1, 0)
                 FROM public.wallets WHERE users_id = ? AND wallets_is_active = 1'
            );
            $next->execute([$userId]);
            $priority = (int)$next->fetchColumn();
            if ($priority > 32767) {
                throw new ApiError(409, 'conflict', 'Đã đạt giới hạn thứ tự ví.');
            }
            $insert = $this->pdo->prepare(
                'INSERT INTO public.wallets (users_id, walletcates_id, wallets_name,
                    wallets_opening_balance, wallets_current_balance, wallets_priority)
                 VALUES (?, ?, ?, ?, ?, ?) RETURNING wallets_id::text'
            );
            $insert->execute([$userId, $type, $name, $balance, $balance, $priority]);
            $id = $insert->fetchColumn();
            $this->pdo->commit();
            return ['id' => $id];
        } catch (Throwable $error) {
            if ($this->pdo->inTransaction()) {
                $this->pdo->rollBack();
            }
            throw $error;
        }
    }

    public function createCategory(int $userId, array $input): array
    {
        $prefix = $this->categoryPrefix($input['type'] ?? null);
        $name = $this->name($input, 150);
        $insert = $this->pdo->prepare(
            "INSERT INTO public.{$prefix}_categories ({$prefix}_name, users_id)
             VALUES (?, ?) RETURNING {$prefix}_id::text"
        );
        $insert->execute([$name, $userId]);
        return ['id' => $insert->fetchColumn()];
    }

    private function name(array $input, int $max): string
    {
        $name = is_string($input['name'] ?? null) ? trim($input['name']) : '';
        if ($name === '' || preg_match_all('/./us', $name) > $max || str_contains($name, "\0")) {
            throw new ApiError(422, 'validation_failed', "Tên phải có từ 1 đến {$max} ký tự.");
        }
        return $name;
    }

    private function page(string $sql, array $params, array $query): array
    {
        $page = $this->positiveInteger($query['page'] ?? '1', PHP_INT_MAX, 'page');
        $size = $this->positiveInteger($query['page_size'] ?? '20', 100, 'page_size');
        if ($page - 1 > intdiv(PHP_INT_MAX, $size)) {
            throw new ApiError(422, 'validation_failed', 'Giá trị page vượt giới hạn.');
        }
        $statement = $this->pdo->prepare($sql . ' LIMIT :limit OFFSET :offset');
        foreach ($params + ['limit' => $size + 1, 'offset' => ($page - 1) * $size] as $name => $value) {
            $statement->bindValue(':' . $name, $value, is_int($value) ? PDO::PARAM_INT : PDO::PARAM_STR);
        }
        $statement->execute();
        $rows = $statement->fetchAll(PDO::FETCH_ASSOC);
        $more = count($rows) > $size;
        if ($more) {
            array_pop($rows);
        }
        return [$rows, ['page' => $page, 'page_size' => $size, 'has_more' => $more]];
    }

    private function positiveInteger(mixed $value, int $max, string $field): int
    {
        if (is_string($value) && preg_match('/^[1-9][0-9]*$/D', $value)
            && ($number = filter_var($value, FILTER_VALIDATE_INT, ['options' => ['max_range' => $max]])) !== false) {
            return $number;
        }
        throw new ApiError(422, 'validation_failed', "Giá trị {$field} không hợp lệ.");
    }
}
