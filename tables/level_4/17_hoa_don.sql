-- ============================================================================
-- 17. HÓA ĐƠN (Level 3)
-- Luồng chính: Bước 5 - Tạo hóa đơn sau khi khám xong
-- Phụ thuộc: lich_hen, phac_do_dieu_tri (optional), nhan_vien
-- ============================================================================

DROP TABLE IF EXISTS hoa_don CASCADE;
CREATE TABLE hoa_don (
    id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_hoa_don                VARCHAR(30) UNIQUE,
    lich_hen_id               UUID NOT NULL
                              REFERENCES lich_hen(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    phac_do_dieu_tri_id       UUID
                              REFERENCES phac_do_dieu_tri(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nhan_vien_id              UUID NOT NULL
                              REFERENCES nhan_vien(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    khuyen_mai_id             UUID
                              REFERENCES khuyen_mai(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    phuong_thuc_thanh_toan    VARCHAR(20)
                              CHECK (phuong_thuc_thanh_toan IN ('tien_mat', 'chuyen_khoan')),
    trang_thai_thanh_toan     VARCHAR(30) NOT NULL DEFAULT 'chua_thanh_toan'
                              CHECK (trang_thai_thanh_toan IN (
                                  'chua_thanh_toan',
                                  'da_thanh_toan', 'da_huy'
                              )),
    ly_do_huy                 TEXT,
    ghi_chu                   TEXT,
    ngay_lap                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ngay_thanh_toan           TIMESTAMPTZ,
    created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_hoa_don_updated_at
    BEFORE UPDATE ON hoa_don
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();