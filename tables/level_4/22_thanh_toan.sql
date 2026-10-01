-- ============================================================================
-- 22. THANH TOÁN (Level 4)
-- Luồng chính: Bước 6 - Bệnh nhân thanh toán hóa đơn
-- Phụ thuộc: hoa_don, nhan_vien
-- ============================================================================

CREATE TABLE thanh_toan (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_thanh_toan    VARCHAR(30) UNIQUE,
    hoa_don_id       UUID NOT NULL
                     REFERENCES hoa_don(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nhan_vien_id     UUID NOT NULL
                     REFERENCES nhan_vien(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    so_tien          DECIMAL(18, 2) NOT NULL,
    phuong_thuc      VARCHAR(20) NOT NULL
                     CHECK (phuong_thuc IN ('tien_mat', 'chuyen_khoan')),
    trang_thai       VARCHAR(20) NOT NULL DEFAULT 'thanh_cong'
                     CHECK (trang_thai IN ('thanh_cong', 'that_bai', 'hoan_tien')),
    ghi_chu          TEXT,
    ngay_thanh_toan  TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_thanh_toan_updated_at
    BEFORE UPDATE ON thanh_toan
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();

