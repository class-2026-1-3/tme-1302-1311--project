-- =======================================================
-- 1. 기존 테이블 삭제 (초기화용)
-- =======================================================
DROP TABLE IF EXISTS game_history;
DROP TABLE IF EXISTS charge_history;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS users;


-- =======================================================
-- 2. 테이블 생성 (DDL)
-- =======================================================

-- ① users 테이블 : user의 정보를 저장하는 테이블
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,       -- 회원 번호
    user_name VARCHAR(100) NOT NULL UNIQUE,       -- 회원 아이디 (로그인용 이메일/ID)
    password VARCHAR(255) NOT NULL,               -- 비밀번호
    coin INT NOT NULL DEFAULT 0,                  -- 보유 코인
    nickname VARCHAR(50) NOT NULL DEFAULT '유저',  -- 화면 표시용 닉네임 (ex: 낙동유저)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ② charge_history 테이블 : 충전 기록 저장
CREATE TABLE charge_history (
    charge_id INT AUTO_INCREMENT PRIMARY KEY,     -- 충전 번호
    user_id INT NOT NULL,                         -- 회원 번호
    amount INT NOT NULL,                          -- 충전 코인
    charge_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 날짜 (오타 교정: data -> date)
    pay_method VARCHAR(20) DEFAULT 'card',        -- 결제 방식 (화면의 카카오, 네이버페이 등 구분용)
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ③ game_history 테이블 : 게임 결과 저장 (오타 교정: gamg -> game)
CREATE TABLE game_history (
    game_history_id INT AUTO_INCREMENT PRIMARY KEY, -- 게임 기록 고유 번호
    game_id INT NOT NULL,                         -- 게임 번호
    user_id INT NOT NULL,                         -- 회원 번호
    game_type VARCHAR(50) NOT NULL,               -- 게임 종류 (ex: 🎰 벅샷 게임, 🎡 룰렛 게임)
    bet_coin INT NOT NULL DEFAULT 0,              -- 베팅 코인
    result VARCHAR(20) NOT NULL,                  -- 승/패 (ex: 'WIN', 'LOSE')
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 날짜
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ④ attendance 테이블 : 화면의 '오늘 출석 완료 ✅'를 위한 부가 테이블
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    attended_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_date (user_id, attended_date)
);

-- ⑤ games 테이블 : 메인 화면에 상점/게임 카드 리스트를 동적으로 뿌리기 위한 테이블
CREATE TABLE games (
    game_id INT AUTO_INCREMENT PRIMARY KEY,
    game_name VARCHAR(50) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    link_url VARCHAR(255)
);


-- =======================================================
-- 3. 초기 데이터 삽입 (DML - HTML 화면 연동용 더미 데이터)
-- =======================================================

-- [유저] 낙동유저 생성 (보유 코인: 12,500)
INSERT INTO users (user_name, password, nickname, coin) 
VALUES ('nakdong@example.com', 'hashed_password_123', '낙동유저', 12500);

-- [출석] 낙동유저 오늘 자 출석 완료 처리
INSERT INTO attendance (user_id, attended_date) 
VALUES (1, CURDATE());

-- [게임 목록] 메인 화면에 들어가는 게임 정보
INSERT INTO games (game_id, game_name, description, image_url, link_url) VALUES 
(1, '🎰 벅샷 게임', '다양한 게임을 즐기고 코인을 획득하세요!', '../zzz.png', 'http://127.0.0.1:5500/html/doback.html'),
(2, '🎡 룰렛 게임', '행운의 룰렛을 돌려 추가 코인을 획득하세요!', '../zzz (2).png', 'http://127.0.0.1:5500/html/doback2.html');

-- [충전 기록 샘플] 과거에 5,000 코인 충전했던 내역
INSERT INTO charge_history (user_id, amount) VALUES (1, 5000);

-- [게임 결과 샘플] 벅샷 게임에서 500 코인 베팅해서 딴 기록
INSERT INTO game_history (game_id, user_id, game_type, bet_coin, result) 
VALUES (1, 1, '🎰 벅샷 게임', 500, 'WIN');


-- =======================================================
-- 4. 웹 화면 연동에 활용할 주요 쿼리 예시
-- =======================================================

-- 1) 메인 화면: 유저 정보 조회 + 오늘 출석 여부 체크
SELECT 
    u.nickname, 
    u.coin,
    IF(a.attendance_id IS NOT NULL, '오늘 출석 완료 ✅', '출석하기 📅') AS attendance_status
FROM users u
LEFT JOIN attendance a ON u.user_id = a.user_id AND a.attended_date = CURDATE()
WHERE u.user_id = 1;

-- 2) 충전 완료 시: 충전 기록 남기고 유저 보유 코인 늘리기
-- (유저 1번이 충전소에서 10,000 코인을 충전했을 때 백엔드에서 실행될 로직)
-- INSERT INTO charge_history (user_id, amount) VALUES (1, 10000);
-- UPDATE users SET coin = coin + 10000 WHERE user_id = 1;