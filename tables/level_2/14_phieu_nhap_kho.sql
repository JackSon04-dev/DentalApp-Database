-- ============================================================================
-- 14. PHIẾU NHẬP KHO (Level 2)
-- Luồng phụ: Quản lý nhập kho vật tư
-- Phụ thuộc: nha_cung_cap, nhan_vien
-- ============================================================================


DROP TABLE IF EXISTS phieu_nhap_kho CASCADE;
CREATE TABLE phieu_nhap_kho (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_phieu_nhap_kho   VARCHAR(30) UNIQUE,
    nha_cung_cap_id UUID NOT NULL
                    REFERENCES nha_cung_cap(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nhan_vien_id    UUID NOT NULL
                    REFERENCES nhan_vien(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay_nhap       TIMESTAMP NOT NULL DEFAULT NOW(),
    trang_thai      VARCHAR(20) NOT NULL DEFAULT 'nhap_moi'
                    CHECK (trang_thai IN ('nhap_moi', 'da_duyet', 'da_huy')),
    nguoi_duyet_id  UUID
                    REFERENCES nhan_vien(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay_duyet      TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_phieu_nhap_kho_updated_at
    BEFORE UPDATE ON phieu_nhap_kho
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();