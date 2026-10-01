-- ============================================================================
-- 25. GIAI ĐOẠN PHÁC ĐỒ (Level 4)
-- Luồng chính: Bản sao chép (Snapshot) từ Phác đồ mẫu, được cá nhân hóa.
-- Chi phí dự kiến được hardcode, mô tả vật tư/dịch vụ lưu dạng text.
-- Dữ liệu FK chính xác chỉ nằm ở dich_vu_dieu_tri và vat_tu_su_dung (qua ho_so_benh_an).
-- Phụ thuộc: phac_do_dieu_tri, lich_hen, self-ref
-- ============================================================================

DROP TABLE IF EXISTS giai_doan_phac_do CASCADE;
CREATE TABLE giai_doan_phac_do (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phac_do_id         UUID NOT NULL
                       REFERENCES phac_do_dieu_tri(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    buoc_cha_id        UUID
                       REFERENCES giai_doan_phac_do(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- 1. THÔNG TIN GIAI ĐOẠN (Sao chép cứng từ phác đồ mẫu)
    buoc_so            INTEGER NOT NULL,
    ten_giai_doan      VARCHAR(200) NOT NULL,
    mo_ta              TEXT,
    
    -- 2. MÔ TẢ VẬT TƯ / DỊCH VỤ (Text snapshot, không nối FK)
    mo_ta_vat_tu_dich_vu TEXT,
    
    -- 3. TÀI CHÍNH (Hardcode)
    chi_phi_du_kien    DECIMAL(18, 2) NOT NULL DEFAULT 0,
    trang_thai_thanh_toan VARCHAR(20) NOT NULL DEFAULT 'chua_thanh_toan'
                       CHECK (trang_thai_thanh_toan IN ('chua_thanh_toan', 'thanh_toan_mot_phan', 'da_thanh_toan')),
    
    -- 4. LIÊN KẾT LUỒNG KHÁM
    lich_hen_id        UUID UNIQUE 
                       REFERENCES lich_hen(id) ON DELETE SET NULL ON UPDATE CASCADE,
                       
    -- 5. TIẾN ĐỘ & TRẠNG THÁI
    trang_thai         VARCHAR(20) NOT NULL DEFAULT 'chua_thuc_hien'
                       CHECK (trang_thai IN (
                           'chua_thuc_hien', 'dang_thuc_hien',
                           'da_hoan_thanh', 'tam_dung', 'bo_qua'
                       )),
    ngay_du_kien       DATE,
    ngay_thuc_hien     DATE,
    co_phat_sinh       BOOLEAN NOT NULL DEFAULT FALSE,
    ghi_chu            TEXT,
    
    created_at         TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_giai_doan_phac_do_updated_at
    BEFORE UPDATE ON giai_doan_phac_do
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
