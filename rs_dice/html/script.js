function generateDots(value) {
    const positions = {
        1: [5],
        2: [3, 7],
        3: [3, 5, 7],
        4: [1, 3, 7, 9],
        5: [1, 3, 5, 7, 9],
        6: [1, 3, 4, 6, 7, 9]
    };

    let html = '';
    for (let i = 1; i <= 9; i++) {
        if (positions[value] && positions[value].includes(i)) {
            html += '<div class="dot"></div>';
        } else {
            html += '<div></div>';
        }
    }
    return html;
}

const container = document.getElementById('dice-container');
const activeDisplays = {};

function rollDiceAnimation(display, dice1, dice2) {
    if (display.rollInterval) clearInterval(display.rollInterval);

    let count = 0;
    display.rollInterval = setInterval(() => {
        display.face1.innerHTML = generateDots(Math.floor(Math.random() * 6) + 1);
        display.face2.innerHTML = generateDots(Math.floor(Math.random() * 6) + 1);
        count++;

        if (count >= 8) {
            clearInterval(display.rollInterval);
            display.rollInterval = null;
            display.face1.innerHTML = generateDots(dice1);
            display.face2.innerHTML = generateDots(dice2);
        }
    }, 80);
}

function updateDice(playerId, dice1, dice2, x, y, visible) {
    let display = activeDisplays[playerId];

    if (!display) {
        const el = document.createElement('div');
        el.className = 'dice-display';
        el.innerHTML = '<div class="dice-face"></div><div class="dice-face"></div>';
        container.appendChild(el);

        display = {
            el: el,
            face1: el.children[0],
            face2: el.children[1],
            rollInterval: null,
            dice1: null,
            dice2: null
        };
        activeDisplays[playerId] = display;
    }

    if (display.dice1 !== dice1 || display.dice2 !== dice2) {
        display.dice1 = dice1;
        display.dice2 = dice2;
        rollDiceAnimation(display, dice1, dice2);
        display.el.classList.add('show');
    }

    if (visible) {
        display.el.style.visibility = 'visible';
        display.el.style.left = (x * 100) + '%';
        display.el.style.top = (y * 100) + '%';
    } else {
        display.el.style.visibility = 'hidden';
    }
}

function hideDice(playerId) {
    const display = activeDisplays[playerId];
    if (!display) return;

    if (display.rollInterval) clearInterval(display.rollInterval);
    display.el.remove();
    delete activeDisplays[playerId];
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'updateDice') {
        updateDice(data.playerId, data.dice1, data.dice2, data.x, data.y, data.visible);
    } else if (data.action === 'hideDice') {
        hideDice(data.playerId);
    }
});
