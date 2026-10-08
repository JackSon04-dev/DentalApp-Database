-- ============================================================================
-- 02. DỊCH VỤ (Level 0 - Bảng gốc)
-- Luồng chính: Danh mục dịch vụ nha khoa để đặt lịch hẹn
-- Phụ thuộc: KHÔNG
-- ============================================================================

DROP TABLE IF EXISTS dich_vu CASCADE;
CREATE TABLE dich_vu (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_dich_vu             VARCHAR(20) UNIQUE,
    ten_dich_vu            VARCHAR(255) NOT NULL,
    mo_ta                  TEXT,
    thong_tin_quy_trinh    TEXT,
    thoi_gian_du_kien_phut INTEGER DEFAULT 30,
    trang_thai             VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                           CHECK (trang_thai IN ('hoat_dong', 'ngung_hoat_dong')),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_dich_vu_updated_at
    BEFORE UPDATE ON dich_vu
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();