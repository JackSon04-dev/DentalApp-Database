-- ============================================================================
-- 06. PHÁC ĐỒ MẪU (Level 0 - Bảng gốc)
-- Luồng phụ: Template phác đồ điều trị
-- Phụ thuộc: KHÔNG
-- ============================================================================

CREATE TABLE phac_do_mau (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_phac_do_mau       VARCHAR(30) UNIQUE,
    ten_phac_do_mau      VARCHAR(200) NOT NULL,
    mo_ta                TEXT,
    so_buoc              INTEGER DEFAULT 0,
    trang_thai           VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                         CHECK (trang_thai IN ('hoat_dong', 'ngung_su_dung')),
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_phac_do_mau_updated_at
    BEFORE UPDATE ON phac_do_mau
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
