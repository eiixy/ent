-- Create "user_audit_logs" table
CREATE TABLE "user_audit_logs" ("id" bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY, "operation_type" character varying NOT NULL, "operation_time" character varying NOT NULL, "old_value" character varying NULL, "new_value" character varying NULL, PRIMARY KEY ("id"));
-- Create "users" table
CREATE TABLE "users" ("id" bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY, "name" character varying NOT NULL, PRIMARY KEY ("id"));
-- Create "audit_users_changes" function
CREATE FUNCTION "audit_users_changes" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO user_audit_logs(operation_type, operation_time, new_value)
        VALUES (TG_OP, CURRENT_TIMESTAMP, row_to_json(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO user_audit_logs(operation_type, operation_time, old_value, new_value)
        VALUES (TG_OP, CURRENT_TIMESTAMP, row_to_json(OLD), row_to_json(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO user_audit_logs(operation_type, operation_time, old_value)
        VALUES (TG_OP, CURRENT_TIMESTAMP, row_to_json(OLD));
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;
-- Create trigger "users_delete_audit"
CREATE TRIGGER "users_delete_audit" AFTER DELETE ON "users" FOR EACH ROW EXECUTE FUNCTION "audit_users_changes"();
-- Create trigger "users_insert_audit"
CREATE TRIGGER "users_insert_audit" AFTER INSERT ON "users" FOR EACH ROW EXECUTE FUNCTION "audit_users_changes"();
-- Create trigger "users_update_audit"
CREATE TRIGGER "users_update_audit" AFTER UPDATE ON "users" FOR EACH ROW EXECUTE FUNCTION "audit_users_changes"();
