-- ============================================================================
-- 26. CHI TIẾT ĐƠN THUỐC (Level 5)
-- Luồng phụ: Từng dòng thuốc trong đơn thuốc kê ngoài
-- Phụ thuộc: don_thuoc
-- ============================================================================

DROP TABLE IF EXISTS chi_tiet_don_thuoc CASCADE;
CREATE TABLE chi_tiet_don_thuoc (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    don_thuoc_id  UUID NOT NULL
                  REFERENCES don_thuoc(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ten_thuoc     VARCHAR(200) NOT NULL,
    hoat_chat     VARCHAR(200),
    ham_luong     VARCHAR(100),
    dang_bao_che  VARCHAR(100),
    lieu_dung     VARCHAR(200),
    so_luong      INTEGER NOT NULL
                  CHECK (so_luong > 0),
    don_vi_tinh   VARCHAR(50),
    so_lan_ngay   INTEGER,
    thoi_diem_uong VARCHAR(100),
    huong_dan     TEXT,
    ghi_chu       TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


CREATE TRIGGER trg_chi_tiet_don_thuoc_updated_at
    BEFORE UPDATE ON chi_tiet_don_thuoc
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
