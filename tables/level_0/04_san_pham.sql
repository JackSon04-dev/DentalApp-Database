-- ============================================================================
-- 04. SẢN PHẨM (Level 0 - Bảng gốc)
-- Lưu theo dạng bảng variant đơn (chỉ lưu 1 bảng chứa thông tin chi tiết)
-- Luồng phụ: Quản lý kho vật tư, dụng cụ, thuốc
-- ============================================================================

DROP TABLE IF EXISTS san_pham CASCADE;
CREATE TABLE san_pham (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_san_pham        VARCHAR(30) UNIQUE,
    ten_san_pham       VARCHAR(200) NOT NULL,
    loai               VARCHAR(50) NOT NULL
                       CHECK (loai IN ('vat_lieu_nha_khoa', 'dung_cu', 'vat_tu')),
    don_vi_tinh        VARCHAR(50) NOT NULL,
    gia_ban            DECIMAL(18, 2) NOT NULL DEFAULT 0,
    so_luong_ton       INTEGER NOT NULL DEFAULT 0,
    muc_ton_toi_thieu  INTEGER NOT NULL DEFAULT 0,
    thuong_hieu        VARCHAR(100),
    xuat_xu            VARCHAR(100),
    mo_ta              TEXT,
    trang_thai         VARCHAR(20) NOT NULL DEFAULT 'dang_hoat_dong'
                       CHECK (trang_thai IN ('dang_hoat_dong', 'ngung_hoat_dong')),
    created_at         TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_san_pham_updated_at
    BEFORE UPDATE ON san_pham
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


