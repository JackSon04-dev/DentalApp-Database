-- ============================================================================
-- 15. LỊCH HẸN (Level 2)
-- Luồng chính: Bước 3 - Bệnh nhân đặt lịch hẹn khám
-- Phụ thuộc: benh_nhan, nha_si, dich_vu, 
-- ============================================================================

CREATE TABLE lich_hen (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_lich_hen          VARCHAR(30) UNIQUE,
    benh_nhan_id         UUID NOT NULL
                         REFERENCES benh_nhan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nha_si_id            UUID NOT NULL
                         REFERENCES nha_si(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    dich_vu_id           UUID NOT NULL
                         REFERENCES dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay_hen             DATE NOT NULL,
    gio_hen              TIME NOT NULL,
    gio_ket_thuc_du_kien TIME,
    trang_thai           VARCHAR(20) NOT NULL DEFAULT 'cho_xac_nhan'
                         CHECK (trang_thai IN (
                             'cho_xac_nhan', 'da_xac_nhan', 'cho_kham',
                             'dang_kham', 'da_kham', 'huy'
                         )),
    ghi_chu              TEXT,
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_lich_hen_updated_at
    BEFORE UPDATE ON lich_hen
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
