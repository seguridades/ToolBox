-- Agrega campos de auditoría a resources
ALTER TABLE resources ADD COLUMN IF NOT EXISTS created_by text;
ALTER TABLE resources ADD COLUMN IF NOT EXISTS updated_by text;
