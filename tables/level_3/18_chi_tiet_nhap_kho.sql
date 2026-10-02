-- ============================================================================
-- 18. CHI TIẾT NHẬP KHO (Level 3)
-- Luồng phụ: Danh sách sản phẩm trong phiếu nhập kho
-- Phụ thuộc: phieu_nhap_kho, san_pham
-- ============================================================================

DROP TABLE IF EXISTS chi_tiet_nhap_kho CASCADE;
CREATE TABLE chi_tiet_nhap_kho (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phieu_nhap_id UUID NOT NULL
                  REFERENCES phieu_nhap_kho(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    san_pham_id   UUID NOT NULL
                  REFERENCES san_pham(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    so_luong      INTEGER NOT NULL,
    don_gia_nhap  DECIMAL(18, 2) NOT NULL,
    so_lo         VARCHAR(50),
    han_su_dung   DATE,
    ghi_chu       VARCHAR(500),
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_chi_tiet_nhap_kho_updated_at
    BEFORE UPDATE ON chi_tiet_nhap_kho
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
