const configEditor = document.getElementById('config-editor');
const closeButton = document.getElementById('close-button');
let configName = "";
let sortedConfig = [];

// Opening the Config Editor
window.addEventListener('message', (event) => {
    if (event.data.type === 'openConfig') {
        configName = event.data.configName;
        sortedConfig = event.data.sortedConfig;
        renderConfig();
        configEditor.classList.remove('hidden');
        document.body.classList.add('active');
    }
});

// Closing the Config Editor
function closeConfigEditor() {
    configEditor.classList.add('hidden');
    document.body.classList.remove('active');

    fetch(`https://${GetParentResourceName()}/closeConfig`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// Escape key to close
window.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
        closeConfigEditor();
    }
});

// Close via the X button
closeButton.addEventListener('click', closeConfigEditor);

// Rendering the Config data
function renderConfig() {
    const configTitle = document.getElementById('config-title');
    configTitle.innerHTML = 'Config Editor - ' + configName;

    const container = document.getElementById('config-container');
    container.innerHTML = '';

    sortedConfig.forEach(setting => {
        const key = setting._key;
        const item = document.createElement('div');
        item.className = 'config-item';

        const label = document.createElement('label');
        label.textContent = key;
        item.appendChild(label);

        const description = document.createElement('p');
        description.textContent = setting.description;
        item.appendChild(description);

        let input;
        if (typeof setting.value === 'object') {
            input = document.createElement('textarea');
            input.value = JSON.stringify(setting.value, null, 2);
            input.rows = 5;
        } else if (typeof setting.value === 'boolean') {
            input = document.createElement('select');
            const trueOption = new Option('true', 'true', setting.value === true);
            const falseOption = new Option('false', 'false', setting.value === false);
            input.add(trueOption);
            input.add(falseOption);

            input.value = setting.value ? 'true' : 'false';
        } else {
            input = document.createElement('input');
            input.type = 'text';
            input.value = setting.value;
        }

        input.dataset.index = sortedConfig.indexOf(setting);
        input.addEventListener('input', () => {
            console.log(`Input changed for ${setting._key}`);
            validateInput(input, setting);
        });

        item.appendChild(input);
        container.appendChild(item);
    });
}

function validateInput(input, setting) {
    if (typeof setting.value === 'object') {
        try {
            JSON.parse(input.value);
            input.classList.remove('invalid');
        } catch (error) {
            input.classList.add('invalid');
            console.error(`Invalid JSON for ${setting._key}`);
        }
    }
}

// Saving changes
document.getElementById('save-button').addEventListener('click', () => {
    const inputs = document.querySelectorAll('#config-container input, #config-container textarea, #config-container select');
    let hasErrors = false;

    inputs.forEach(input => {
        const index = input.dataset.index;
        const setting = sortedConfig[index];

        if (typeof setting.value === 'object') {
            try {
                setting.value = JSON.parse(input.value);
                input.classList.remove('invalid');
            } catch (error) {
                input.classList.add('invalid');
                hasErrors = true;
            }
        } else if (typeof setting.value === 'boolean') {
            setting.value = input.value === 'true';
        } else {
            setting.value = input.value;
        }
    });

    if (hasErrors) {
        return;
    }

    fetch(`https://${GetParentResourceName()}/saveConfig`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            type: 'saveConfig',
            configName: configName,
            sortedConfig
        })
    });

    closeConfigEditor();
});