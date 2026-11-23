-- Link the existing application user row to Supabase Auth without adding a table.
ALTER TABLE public.users
    ADD COLUMN users_supabase_uid uuid UNIQUE;

CREATE SCHEMA IF NOT EXISTS ourbudget_private;
REVOKE ALL ON SCHEMA ourbudget_private FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION ourbudget_private.sync_auth_user_to_profile()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    profile_name text;
    profile_avatar text;
BEGIN
    IF NEW.email IS NULL OR pg_catalog.btrim(NEW.email) = '' THEN
        RETURN NEW;
    END IF;

    profile_name := pg_catalog.left(
        COALESCE(
            NULLIF(pg_catalog.btrim(NEW.raw_user_meta_data ->> 'full_name'), ''),
            NULLIF(pg_catalog.btrim(NEW.raw_user_meta_data ->> 'name'), ''),
            pg_catalog.split_part(NEW.email, '@', 1)
        ),
        50
    );
    profile_avatar := NEW.raw_user_meta_data ->> 'avatar_url';

    UPDATE public.users
       SET users_email = pg_catalog.lower(NEW.email),
           users_name = profile_name,
           users_avatar_url = COALESCE(profile_avatar, users_avatar_url),
           users_verified_at = CASE WHEN NEW.email_confirmed_at IS NULL THEN NULL ELSE COALESCE(users_verified_at, NEW.email_confirmed_at) END,
           users_welcomed_at = CASE WHEN NEW.email_confirmed_at IS NULL THEN users_welcomed_at ELSE COALESCE(users_welcomed_at, CURRENT_TIMESTAMP) END,
           users_updated_at = CURRENT_TIMESTAMP
     WHERE users_supabase_uid = NEW.id;
    IF FOUND THEN
        RETURN NEW;
    END IF;

    IF NEW.email_confirmed_at IS NOT NULL THEN
        UPDATE public.users
           SET users_supabase_uid = NEW.id,
               users_verified_at = COALESCE(users_verified_at, NEW.email_confirmed_at),
               users_updated_at = CURRENT_TIMESTAMP
         WHERE pg_catalog.lower(users_email) = pg_catalog.lower(NEW.email)
           AND users_supabase_uid IS NULL;
        IF FOUND THEN
            RETURN NEW;
        END IF;
    END IF;

    INSERT INTO public.users (
        users_supabase_uid, users_name, users_email, users_avatar_url,
        users_verified_at, users_welcomed_at
    ) VALUES (
        NEW.id, profile_name, pg_catalog.lower(NEW.email), profile_avatar,
        NEW.email_confirmed_at, CASE WHEN NEW.email_confirmed_at IS NULL THEN NULL ELSE CURRENT_TIMESTAMP END
    )
    ON CONFLICT (users_email) DO NOTHING;

    RETURN NEW;
END;
$$;

CREATE TRIGGER sync_auth_user_after_insert
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION private.sync_auth_user_to_profile();

CREATE TRIGGER sync_auth_user_after_update
AFTER UPDATE OF email, email_confirmed_at, raw_user_meta_data ON auth.users
FOR EACH ROW EXECUTE FUNCTION private.sync_auth_user_to_profile();
