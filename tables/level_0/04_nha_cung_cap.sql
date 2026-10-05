-- ============================================================================
-- 05. NHÀ CUNG CẤP (Level 0 - Bảng gốc)
-- Luồng phụ: Quản lý nhà cung cấp vật tư
-- Phụ thuộc: KHÔNG
-- ============================================================================

DROP TABLE IF EXISTS nha_cung_cap CASCADE;
CREATE TABLE nha_cung_cap (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_ncc            VARCHAR(30) UNIQUE,
    ten_ncc           VARCHAR(200) NOT NULL,
    dia_chi           VARCHAR(500),
    sdt               VARCHAR(20) UNIQUE,
    email             VARCHAR(150),
    ma_so_thue        VARCHAR(20),
    nguoi_lien_he     VARCHAR(150),
    sdt_nguoi_lien_he VARCHAR(20),
    ghi_chu           TEXT,
    trang_thai        VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                      CHECK (trang_thai IN ('hoat_dong', 'ngung_hoat_dong')),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_nha_cung_cap_updated_at
    BEFORE UPDATE ON nha_cung_cap
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
