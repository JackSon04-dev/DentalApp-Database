-- ============================================================================
-- 20. DỊCH VỤ ĐIỀU TRỊ (Level 4)
-- Luồng chính: Bước 4b - Chi tiết dịch vụ đã thực hiện trong buổi khám
-- Phụ thuộc: ho_so_benh_an, dich_vu, nha_si
-- ============================================================================

CREATE TABLE dich_vu_dieu_tri (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ho_so_id    UUID NOT NULL
                REFERENCES ho_so_benh_an(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    chi_tiet_dich_vu_id  UUID NOT NULL
                REFERENCES chi_tiet_dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    so_luong    INTEGER NOT NULL DEFAULT 1,
    don_gia     DECIMAL(18, 2) NOT NULL,
    giam_gia    DECIMAL(18, 2) NOT NULL DEFAULT 0,
    thanh_tien  DECIMAL(18, 2) NOT NULL,
    vi_tri_rang VARCHAR(50),
    ghi_chu     TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_dich_vu_dieu_tri_updated_at
    BEFORE UPDATE ON dich_vu_dieu_tri
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();



