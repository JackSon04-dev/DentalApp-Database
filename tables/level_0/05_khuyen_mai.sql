-- ============================================================================
-- 05. KHUYẾN MÃI / VOUCHER (Level 0)
-- Luồng phụ: Quản lý các chương trình giảm giá, voucher
-- Phụ thuộc: KHÔNG
-- ============================================================================

DROP TABLE IF EXISTS khuyen_mai CASCADE;
CREATE TABLE khuyen_mai (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_khuyen_mai  VARCHAR(30) UNIQUE NOT NULL,
    ten_chuong_trinh VARCHAR(200) NOT NULL,
    loai_giam      VARCHAR(20) NOT NULL CHECK (loai_giam IN ('phan_tram', 'so_tien')),
    gia_tri_giam   DECIMAL(18, 2) NOT NULL CHECK (gia_tri_giam > 0),
    ngay_bat_dau   DATE NOT NULL,
    ngay_ket_thuc  DATE NOT NULL,
    so_lan_su_dung_toi_da INTEGER,
    so_lan_da_su_dung     INTEGER NOT NULL DEFAULT 0,
    trang_thai     VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                   CHECK (trang_thai IN ('hoat_dong', 'het_han', 'da_huy')),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_ngay_khuyen_mai CHECK (ngay_ket_thuc >= ngay_bat_dau)
);

CREATE TRIGGER trg_khuyen_mai_updated_at
    BEFORE UPDATE ON khuyen_mai
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
