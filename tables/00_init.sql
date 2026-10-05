-- ============================================================================
-- FILE KHỞI TẠO: Extension + Trigger Function
-- Chạy file này ĐẦU TIÊN trước khi import bất kỳ table nào
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Trigger function tự động cập nhật updated_at
CREATE OR REPLACE FUNCTION fn_cap_nhat_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
