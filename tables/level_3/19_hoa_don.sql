-- ============================================================================
-- 19. HÓA ĐƠN (Level 3)
-- Luồng chính: Bước 5 - Tạo hóa đơn sau khi khám xong
-- Phụ thuộc: lich_hen, phac_do_dieu_tri (optional)
-- ============================================================================

CREATE TABLE hoa_don (
    id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_hoa_don                VARCHAR(30) UNIQUE,
    lich_hen_id               UUID NOT NULL
                              REFERENCES lich_hen(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    phac_do_dieu_tri_id       UUID
                              REFERENCES phac_do_dieu_tri(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    tong_tien_truoc_giam_gia  DECIMAL(18, 2) NOT NULL DEFAULT 0,
    tong_tien_sau_giam_gia    DECIMAL(18, 2) NOT NULL DEFAULT 0,
    so_tien_da_thanh_toan     DECIMAL(18, 2) NOT NULL DEFAULT 0,
    so_tien_con_lai           DECIMAL(18, 2) NOT NULL DEFAULT 0,
    trang_thai_thanh_toan     VARCHAR(30) NOT NULL DEFAULT 'chua_thanh_toan'
                              CHECK (trang_thai_thanh_toan IN (
                                  'chua_thanh_toan', 'thanh_toan_mot_phan',
                                  'da_thanh_toan', 'da_huy'
                              )),
    ghi_chu                   TEXT,
    ngay_lap                  TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at                TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at                TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_hoa_don_updated_at
    BEFORE UPDATE ON hoa_don
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();