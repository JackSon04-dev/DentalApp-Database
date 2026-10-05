-- ============================================================================
-- 01. TÀI KHOẢN (Level 0 - Bảng gốc)
-- Luồng chính: Bước 1 - Tạo tài khoản đăng nhập
-- Phụ thuộc: KHÔNG
-- ============================================================================

DROP TABLE IF EXISTS tai_khoan CASCADE;
CREATE TABLE tai_khoan (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username           VARCHAR(100) NOT NULL UNIQUE,
    password_hash      VARCHAR(255),
    google_id          VARCHAR(255) UNIQUE, -- Lưu mã định danh của Google
    loai_tai_khoan     VARCHAR(20)  NOT NULL
                       CHECK (loai_tai_khoan IN ('benh_nhan', 'nha_si', 'nhan_vien', 'admin')),
    trang_thai         VARCHAR(20)  NOT NULL DEFAULT 'hoat_dong'
                       CHECK (trang_thai IN ('hoat_dong', 'bi_khoa')),
    refresh_token_hash VARCHAR(500),
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_tai_khoan_updated_at
    BEFORE UPDATE ON tai_khoan
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
