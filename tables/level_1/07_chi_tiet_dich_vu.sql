-- ============================================================================
-- 07. CHI TIẾT DỊCH VỤ (Level 1)
-- Phụ thuộc: dich_vu
-- ============================================================================

DROP TABLE IF EXISTS chi_tiet_dich_vu CASCADE;
CREATE TABLE chi_tiet_dich_vu (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dich_vu_id             UUID NOT NULL
                           REFERENCES dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ma_chi_tiet            VARCHAR(20) UNIQUE,
    ten_chi_tiet           VARCHAR(200) NOT NULL,
    gia                    DECIMAL(18, 2) NOT NULL DEFAULT 0
                           CHECK (gia >= 0),
    don_vi_tinh            VARCHAR(50),
    trang_thai             VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                           CHECK (trang_thai IN ('hoat_dong', 'ngung_hoat_dong')),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_chi_tiet_dich_vu_updated_at
    BEFORE UPDATE ON chi_tiet_dich_vu
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();