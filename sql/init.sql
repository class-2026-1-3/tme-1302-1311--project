-- =======================================================
-- 1. 기존 테이블 삭제 (초기화용 - 순서 중요: 외래키 관계 고려)
-- =======================================================
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS charge_products;
DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS users;


-- =======================================================
-- 2. 테이블 생성 (DDL)
-- =======================================================

-- ① 유저 테이블 (회원가입, 로그인, 메인화면 우측 '내 정보' 연동)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,          -- 로그인 ID (이메일)
    password VARCHAR(255) NOT NULL,              -- 암호화된 비밀번호
    nickname VARCHAR(50) NOT NULL DEFAULT '유저', -- 화면 표시 닉네임 (ex: 낙동유저)
    coins INT NOT NULL DEFAULT 0,                -- 보유 코인 (ex: 12,500 코인)
    profile_img VARCHAR(255) DEFAULT NULL,       -- 프로필 이미지 경로
    social_provider VARCHAR(20) DEFAULT 'local', -- 로그인 경로 ('local', 'naver', 'google')
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ② 출석 체크 테이블 (화면의 '오늘 출석 완료 ✅' 상태 판별용)
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    attended_date DATE NOT NULL,                 -- 출석 날짜 (년-월-일)
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_date (user_id, attended_date) -- 하루에 단 한 번만 출석 가능하도록 제한
);

-- ③ 게임 목록 테이블 (메인화면의 벅샷게임, 룰렛게임 카드 정보 관리)
CREATE TABLE games (
    game_id INT AUTO_INCREMENT PRIMARY KEY,
    game_name VARCHAR(50) NOT NULL,              -- 게임 타이틀 (ex: 🎰 벅샷 게임)
    description TEXT,                            -- 게임 설명 문구
    image_url VARCHAR(255),                      -- 게임 카드 이미지 경로
    link_url VARCHAR(255),                       -- [입장하기] 버튼 이동 링크
    is_active BOOLEAN DEFAULT TRUE               -- 게임 활성화/점검 여부
);

-- ④ 코인 충전 상품 테이블 (충전소 페이지 왼쪽의 상품 리스트)
CREATE TABLE charge_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    coin_amount INT NOT NULL,                    -- 충전될 코인 수량 (ex: 10000)
    price INT NOT NULL,                          -- 결제 가격 (원화 상품 가격)
    product_image VARCHAR(255)                   -- 상품 박스에 들어갈 이미지 경로
);

-- ⑤ 결제 및 충전 내역 테이블 (충전소 오른쪽 결제 영역 및 마이페이지 연동)
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    pay_method VARCHAR(20) NOT NULL,             -- 결제 방식 (ex: 'card', 'kakao', 'naver')
    total_price INT NOT NULL,                    -- 실제 결제 금액
    status VARCHAR(20) DEFAULT 'COMPLETED',      -- 결제 상태 (PENDING, COMPLETED, CANCELED)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES charge_products(product_id)
);


-- =======================================================
-- 3. 초기 데이터 삽입 (DML - HTML 화면 매칭용)
-- =======================================================

-- ① 테스트 유저 생성 (낙동유저 / 보유 코인: 12,500)
INSERT INTO users (email, password, nickname, coins) 
VALUES ('nakdong@example.com', '$2b$10$xyz...', '낙동유저', 12500);

-- ② 낙동유저 오늘 날짜로 출석 완료 처리 (CURDATE()는 현재 날짜를 자동으로 입력합니다)
INSERT INTO attendance (user_id, attended_date) 
VALUES (1, CURDATE());

-- ③ 메인 화면 게임 카드 리스트 등록
INSERT INTO games (game_name, description, image_url, link_url) VALUES 
('🎰 벅샷 게임', '다양한 게임을 즐기고 코인을 획득하세요!', '../zzz.png', 'http://127.0.0.1:5500/html/doback.html'),
('🎡 룰렛 게임', '행운의 룰렛을 돌려 추가 코인을 획득하세요!', '../zzz (2).png', 'http://127.0.0.1:5500/html/doback2.html');

-- ④ 충전소 코인 상품 리스트 등록
INSERT INTO charge_products (coin_amount, price, product_image) VALUES 
(5000, 5000, '../coin_5k.png'),
(10000, 10000, '../coin_10k.png'),
(30000, 30000, '../coin_30k.png'),
(50000, 50000, '../coin_50k.png');


-- =======================================================
-- 4. 백엔드 연동 핵심 쿼리 샘플 (참고용)
-- =======================================================

-- [조회] 메인 화면: 로그인한 유저(ID: 1) 정보 및 오늘 출석 여부(0 또는 1) 한 번에 가져오기
SELECT 
    u.nickname, 
    u.coins,
    IF(a.attendance_id IS NOT NULL, 1, 0) AS is_attended_today
FROM users u
LEFT JOIN attendance a ON u.user_id = a.user_id AND a.attended_date = CURDATE()
WHERE u.user_id = 1;

-- [조회] 메인 화면: 활성화된 게임 리스트 순서대로 가져오기
SELECT game_name, description, image_url, link_url FROM games WHERE is_active = TRUE;

-- [조회] 충전소 화면: 판매 중인 코인 상품 목록 조회
SELECT product_id, coin_amount, price, product_image FROM charge_products;

-- [기능] 충전소 화면: 유저가 상품 결제 완료 시 (내역 추가 + 코인 지급)
-- INSERT INTO payments (user_id, product_id, pay_method, total_price) VALUES (1, 2, 'kakao', 10000);
-- UPDATE users SET coins = coins + 10000 WHERE user_id = 1;