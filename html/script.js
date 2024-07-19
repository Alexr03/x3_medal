const uiResource = 'https://x3_medal'
const medalApi = 'http://localhost:12665'
let publicKey = null;
let setupData = null;
let isSetup = false;

window.addEventListener("message", async (event) => {
    let rootData = event.data;
    let action = rootData.action;
    let data = rootData.data;

    if (action === 'InvokeGameEvent') {
        await invokeGameEvent(data)
    }
    else if (action === 'Setup') {
        setupData = data;
        await setupMedal(setupData);
    }
    else if (action === 'CloseUI') {
        closeUI();
    }
    else if (action === 'OpenUI') {
        openUI();
    }
    else {
        console.error('Unknown action', action);
    }
});

// If user pressed escape, close the UI
document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
        closeUI();
    }
});

function openUI() {
    let controlPanel = document.getElementById('control-panel');
    // Remove animate__backOutRight
    controlPanel.classList.remove('animate__backOutRight');
    controlPanel.classList.add('animate__backInRight');

    // Set visibility to visible
    controlPanel.style.visibility = 'visible';
}

function closeUI() {
    let controlPanel = document.getElementById('control-panel');
    // Remove animate__backInRight
    controlPanel.classList.remove('animate__backInRight');
    controlPanel.classList.add('animate__backOutRight');

    // Send POST request to /Closed
    fetch(`${uiResource}/Closed`, {
        method: 'POST'
    });
}

function createEventButtons(events) {

    // Clear out existing events
    document.getElementById('events-container').innerHTML = '';

    // Add in order of .UISettings.Order
    events.sort((a, b) => a.UISettings.Order - b.UISettings.Order);

    events.forEach(event => {
        if (event.UISettings && event.UISettings.Visible) {
            addEventToUi(event);
        }
    });
}

function addEventToUi(eventData) {
    const eventsContainer = document.getElementById('events-container');

    let eventDiv = document.createElement('div');
    eventDiv.className = 'event';
    eventDiv.innerHTML = `
        <span class="event-title">${eventData.UISettings.Name}</span>
        <div class="event-actions">
            <div class="icon-toggle">
                <i class="fas fa-camera ${eventData.Settings.ClipEnabled ? 'active' : ''}"></i>
            </div>
            <div class="icon-toggle">
                <i class="fas fa-volume-up ${eventData.Settings.SoundEnabled ? 'active' : ''}"></i>
            </div>
        </div>
        <span class="event-description">${eventData.UISettings.Description ?? "N/A"}</span>
    `;

    const cameraIcon = eventDiv.querySelector('.fa-camera');
    const soundIcon = eventDiv.querySelector('.fa-volume-up');

    cameraIcon.addEventListener('click', async () => {
        cameraIcon.classList.toggle('active');
        await invokeEventSettingsChanged(eventData.EventId, cameraIcon.classList.contains('active'), soundIcon.classList.contains('active'));
    });

    soundIcon.addEventListener('click', async () => {
        soundIcon.classList.toggle('active');
        await invokeEventSettingsChanged(eventData.EventId, cameraIcon.classList.contains('active'), soundIcon.classList.contains('active'));
    });

    eventsContainer.appendChild(eventDiv);
}

async function fetchWithTimeout(resource, options = {}) {
    const { timeout = 8000 } = options;

    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), timeout);

    const response = await fetch(resource, {
        ...options,
        signal: controller.signal
    });
    clearTimeout(id);

    return response;
}

async function setupMedal(setupData) {
    publicKey = setupData.PublicKey;
    createEventButtons(setupData.Events);
    await invokeSubmitContext(setupData.GameContext);
    await invokeUserInfoCallback();

    isSetup = true;
}

async function invokeSubmitContext(gameContext) {
    let response = await fetch(`${medalApi}/api/v1/context/submit`, {
        method: 'POST',
        headers: {
            'publicKey': publicKey,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(gameContext)
    });

    if (!response.ok) {
        throw new Error('Failed to submit game context');
    }

    return await response.json();
}

async function invokeGameEvent(data) {

    if(!isSetup) {
        console.error('Medal is not setup');
        return;
    }

    let response = await fetch(`${medalApi}/api/v1/event/invoke`, {
        method: 'POST',
        headers: {
            'publicKey': publicKey,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    });

    if (!response.ok) {
        throw new Error('Failed to invoke game event');
    }

    return await response.json();
}

async function invokeEventSettingsChanged(eventId, clipEnabled, soundEnabled) {
    // Create POST request to /EventSettingsChanged
    await fetch(`${uiResource}/EventSettingsChanged`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            EventId: eventId,
            ClipEnabled: clipEnabled,
            SoundEnabled: soundEnabled
        })
    });
}

async function invokeUserInfoCallback() {

    let medalUserInfo = await getMedalUserInfo();

    // Create POST request to /SetUserInfo
    fetch(`${uiResource}/SetUserInfo`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        // body: JSON.stringify(medalUserInfo)
        body: JSON.stringify({
            UserId: medalUserInfo.UserId,
            Username: medalUserInfo.Username
        })
    });
}

async function getMedalUserInfo() {
    // Create GET request to /api/v1/user/info
    let response = await fetch(`${medalApi}/api/v1/user/profile`, {
        method: 'GET',
    });

    if (!response.ok) {
        throw new Error('Failed to get Medal user info');
    }

    let json = await response.json()
    return {
        UserId: json.userId,
        Username: json.userName,
    }
}

async function getIsMedalActive() {
    try {
        await fetchWithTimeout(`${medalApi}/api/v1/user/profile`, {
            method: 'GET',
            timeout: 1000
        });
        return true;
    } catch (e) {
        return false;
    }
}

// Periodically check if Medal is active
setInterval(async () => {
    let isMedalActive = await getIsMedalActive();

    if (!isMedalActive) {
        let errorStatus = document.getElementById('status');
        let statusText = document.getElementById('status-text');
        errorStatus.style.display = 'block';
        errorStatus.classList.add('error');
        statusText.innerText = 'Cannot connect to medal';

        isSetup = false;
    } else {
        let errorStatus = document.getElementById('status');
        errorStatus.style.display = 'none';
        errorStatus.classList.remove('error');

        if (!isSetup) {
            await setupMedal(setupData);
        }
    }
}, 5000);

// When clip-now-btn is clicked, send POST request to /ClipNow
document.getElementById('clip-now-btn').addEventListener('click', async () => {
    await fetch(`${uiResource}/ClipNow`, {
        method: 'POST'
    });
});