document.addEventListener("DOMContentLoaded", () => {
    const canvas = document.getElementById("roulette-wheel");
    const ctx = canvas.getContext("2d");
    const spinBtn = document.getElementById("spin-btn");
    const betInput = document.getElementById("bet-amount");
    const btnMin = document.getElementById("btn-min");
    const btnPlus = document.getElementById("btn-plus");
    const userCoinsDisplay = document.getElementById("user-coins");
    const resultMessage = document.getElementById("result-message");

    let userCoins = 1000;
    let isSpinning = false;

    // 시안 이미지 배치 순서 매칭 (12시 방향 기준 순차 배치)
    const prizes = [
        { label: "꽝", multiplier: 0 },
        { label: "2배", multiplier: 2 },
        { label: "꽝", multiplier: 0 },
        { label: "3배", multiplier: 3 },
        { label: "꽝", multiplier: 0 },
        { label: "1.5배", multiplier: 1.5 },
        { label: "대박 5배", multiplier: 5 },
        { label: "꽝", multiplier: 0 }
    ];

    const numSegments = prizes.length;
    const segmentAngle = (2 * Math.PI) / numSegments;

    function drawWheel() {
        const radius = canvas.width / 2;
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        for (let i = 0; i < numSegments; i++) {
            const angle = i * segmentAngle;

            // 조각 배경 (완전한 블랙)
            ctx.beginPath();
            ctx.fillStyle = "#000000";
            ctx.moveTo(radius, radius);
            ctx.arc(radius, radius, radius - 15, angle, angle + segmentAngle);
            ctx.closePath();
            ctx.fill();

            // 구분선 (빛나는 노란색 테두리)
            ctx.strokeStyle = "#f3c65f";
            ctx.lineWidth = 2;
            ctx.stroke();

            // 텍스트 그리기 (바깥에서 안쪽으로 올바르게 읽히도록 회전각 조정)
            ctx.save();
            ctx.translate(radius, radius);
            ctx.rotate(angle + segmentAngle / 2);
            
            // 글씨가 뒤집히지 않도록 정렬 기준 매칭
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillStyle = "#f3c65f";
            ctx.font = "bold 18px 'Malgun Gothic'";
            
            // 중심축 기준 적절한 내부 여백 배치
            ctx.fillText(prizes[i].label, radius - 60, 0);
            ctx.restore();
        }

        // 외곽 메인 황금 링 테두리
        ctx.beginPath();
        ctx.strokeStyle = "#f3c65f";
        ctx.lineWidth = 6;
        ctx.arc(radius, radius, radius - 15, 0, 2 * Math.PI);
        ctx.stroke();

        // 중앙 골드 코어 링 인프라 데코레이션
        ctx.beginPath();
        ctx.fillStyle = "#f3c65f";
        ctx.arc(radius, radius, 35, 0, 2 * Math.PI);
        ctx.fill();

        ctx.beginPath();
        ctx.fillStyle = "#000000";
        ctx.arc(radius, radius, 22, 0, 2 * Math.PI);
        ctx.fill();

        ctx.beginPath();
        ctx.strokeStyle = "#f3c65f";
        ctx.lineWidth = 2;
        ctx.arc(radius, radius, 12, 0, 2 * Math.PI);
        ctx.stroke();
    }

    drawWheel();

    // 최소 금액 세팅
    btnMin.addEventListener("click", () => {
        if (!isSpinning) betInput.value = 10;
    });

    // 금액 추가 세팅
    btnPlus.addEventListener("click", () => {
        if (!isSpinning) {
            let cur = parseInt(betInput.value) || 0;
            betInput.value = cur + 10;
        }
    });

    // 스핀 제어 메커니즘
    spinBtn.addEventListener("click", () => {
        if (isSpinning) return;

        const betAmount = parseInt(betInput.value);

        if (isNaN(betAmount) || betAmount <= 0) {
            resultMessage.textContent = "올바른 베팅 코인을 입력하세요.";
            return;
        }
        if (betAmount > userCoins) {
            resultMessage.textContent = "잔여 코인이 부족합니다.";
            return;
        }

        isSpinning = true;
        spinBtn.disabled = true;
        userCoins -= betAmount;
        userCoinsDisplay.textContent = userCoins.toLocaleString();
        resultMessage.textContent = "로젯판이 돌아가고 있습니다! 대박을 노려보세요.";

        // 애니메이션 다이내믹 휠 스핀 연산
        const minRotation = 360 * 7; 
        const randomRotation = Math.floor(Math.random() * 360);
        const totalDegrees = minRotation + randomRotation;

        canvas.style.transform = `rotate(${totalDegrees}deg)`;

        setTimeout(() => {
            isSpinning = false;
            spinBtn.disabled = false;

            const actualDegrees = totalDegrees % 360;
            // 12시 방향 빨간 바늘 정밀 정산 공식 적용
            const normalizedAngle = (360 - actualDegrees + 270) % 360;
            const winningIndex = Math.floor((normalizedAngle / 360) * numSegments) % numSegments;

            const winPrize = prizes[winningIndex];

            if (winPrize.multiplier > 0) {
                const winAmount = Math.floor(betAmount * winPrize.multiplier);
                userCoins += winAmount;
                resultMessage.textContent = `축하합니다! [${winPrize.label}] 당첨! +${winAmount} 코인을 획득했습니다.`;
            } else {
                resultMessage.textContent = `아쉽게도 [꽝]입니다. 다음 기회를 노려보세요!`;
            }

            userCoinsDisplay.textContent = userCoins.toLocaleString();

            // 연속 스핀 안정화 초기화 작업
            canvas.style.transition = "none";
            canvas.style.transform = `rotate(${actualDegrees}deg)`;
            setTimeout(() => {
                canvas.style.transition = "transform 5s cubic-bezier(0.15, 0.85, 0.15, 1)";
            }, 50);

        }, 5000);
    });
});