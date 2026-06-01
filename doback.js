const cntBox = document.getElementById("countTest2");
const numbersHTML = "0123456789".split("").map(n => `<div>${n}</div>`).join("");

function RollingNum(number) { 
  cntBox.innerHTML = "";

  number.split("").forEach(targetNum => {

    const numSpan = document.createElement("span");
    numSpan.className = "num";

    numSpan.innerHTML = `<span class="numList">${numbersHTML}</span>`;
    cntBox.appendChild(numSpan);
    numSpan.querySelector(".numList").style.transform = `translateY(${targetNum * -120}px)`;
  });
}

document.getElementById("startBtn").addEventListener("click", () => {
  RollingNum(String(Math.floor(Math.random() * 1000)).padStart(3, "0"));
});

RollingNum("000");