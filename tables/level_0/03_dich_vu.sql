-- ============================================================================
-- 03. DỊCH VỤ (Level 0 - Bảng gốc)
-- Tách thành 2 bảng: dich_vu (bảng cha) và chi_tiet_dich_vu (bảng con/variant)
-- Luồng chính: Danh mục dịch vụ nha khoa để đặt lịch hẹn
-- ============================================================================

CREATE TABLE dich_vu (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_dich_vu             VARCHAR(20) UNIQUE,
    ten_dich_vu            VARCHAR(255) NOT NULL,
    mo_ta                  TEXT,
    thong_tin_quy_trinh    TEXT,
    thoi_gian_du_kien_phut INTEGER DEFAULT 30,
    trang_thai             VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                           CHECK (trang_thai IN ('hoat_dong', 'ngung_cung_cap')),
    created_at             TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_dich_vu_updated_at
    BEFORE UPDATE ON dich_vu
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- Bảng con: Chi Tiết Dịch Vụ (Variants)
CREATE TABLE chi_tiet_dich_vu (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dich_vu_id             UUID NOT NULL
                           REFERENCES dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ten_chi_tiet           VARCHAR(200) NOT NULL,
    gia                    DECIMAL(18, 2) NOT NULL DEFAULT 0,
    don_vi_tinh            VARCHAR(50),
    trang_thai             VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                           CHECK (trang_thai IN ('hoat_dong', 'ngung_cung_cap')),
    created_at             TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_chi_tiet_dich_vu_updated_at
    BEFORE UPDATE ON chi_tiet_dich_vu
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();

