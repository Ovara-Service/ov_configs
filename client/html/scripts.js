const configEditor = document.getElementById('config-editor');
const closeButton = document.getElementById('close-button');
let configName = "Default Config";
let sortedConfig = [];

const loadDefaultConfig = false;

// Default configuration
const defaultConfig = {
    configName: "BanSystemConfig",
    sortedConfig: [
        { _key: "warnSystemPermissions", value: ["superadmin", "admin", "srmod", "mod", "srsup", "dev", "content", "sup"], description: "Permissions for the warn system." },
        { _key: "banBypassOffset", value: -0.75, description: "Offset for ban bypass duration." },
        { _key: "themeDesign", value: {
                "color-primary": "rgb(178, 55, 55)",
                "color-secondary": "#ffffff",
                "color-accent": "rgba(255, 255, 255, 0.2)",
                "primary-background": "rgba(24, 4, 0, 0.8)",
                "secondary-background": "rgba(215, 127, 69, 0)",
                "background-card": "#181210",
                "primary-hover-color": "rgb(178, 73, 55)",
                "primary-hover-color-2": "rgba(223, 53, 1, 0)",
                "primary-hover-color-3": "#181310",
                "primary-hover-border-color": "rgba(149, 53, 36, 0.85)",
                "secondary-hover-color": "#FFFFFF"
            }, description: "Design theme." },
        { _key: "requireIdentifiers", value: { discord: true, steam: true }, description: "Required player identifiers to join server." },
        { _key: "deleteWarnsOnBan", value: true, description: "Should warns be deleted when warn" },
        { _key: "addons", value: { Waveshield: { reason: "Modding #16", useKick: true, enabled: true, addRealReasonToBanNote: true } }, description: "Additional addon configurations." },
        {
            _key: "adminJail",
            value: {
                jailOuts: { locations: [{ x: 1846.4832999999636, heading: 272.8153999999631, z: 45.67280000000028, y: 2585.8057000003757 }] },
                centralPosition: { location: { x: -318.1328999999678, heading: 135.82789999997477, z: 11.12589999999909, y: -4051.466599999927 }, maxDistance: 150 },
                timeFasterShorten: { distance: { min: 10, max: 30 }, enable: true, duration: 30, timeRemovedPerLocation: 1 },
                jails: { locations: [{ x: -318.1328999999678, heading: 135.82789999997477, z: 11.12589999999909, y: -4051.466599999927 }] },
                remainingTimeTextPosition: { outline: true, y: 0.95000000000004, a: 255, g: 91, r: 4, x: 0.29999999999995, b: 250, scale: 0.5 },
                permissions: ["superadmin", "admin", "srmod", "mod", "srsup", "dev", "content", "sup"]
            },
            description: "Admin jail settings.",
            client: true
        },
        { _key: "autoUnban", value: { blacklistedIdentifier: [], enabled: true, doNotUnBanAfter: { year: 2024, month: 10, day: 29 } }, description: "Auto unban configuration." },
        { _key: "chatMsgColor", value: [255, 0, 0], description: "Chat message color" },
        { _key: "reportSystem", value: { delay: 30, enabled: true }, description: "Report system settings." },
        {
            _key: "smartBans",
            value: {
                permAfter: 10,
                enabled: true,
                offsets: { "8": 0.79999999999995, "9": 1.0, "6": 0.5, "7": 0.5999999999999, "4": 0.35000000000002, "5": 0.39999999999997, "3": 0.25 },
                continousOffset: { offset: 0.79999999999995, enabled: true }
            },
            description: "Smart bans configuration."
        },
        { _key: "logger", value: { enabled: true, adminJail: "bansystem_jails", storageName: "bansystem", reportStorageName: "bansystem_reports", resourceName: "yss_logger" }, description: "Logger settings" },
        { _key: "timeBanCache", value: 5, description: "Time in minutes for the ban cache." },
        { _key: "locale", value: "de", sort: 2, description: "Language settings", client: true },
        { _key: "debug", value: true, sort: 1, description: "Enable debug mode for ovara configs.", client: true },
        {
            _key: "commands",
            value: {
                delban: { permissions: ["superadmin"], enabled: true, name: "delban" },
                listTemplates: { permissions: ["superadmin", "admin", "srmod", "mod", "srsup", "dev", "content"], enabled: true, name: ["templates", "listTemplates", "lstemplates", "lstemp", "lst"] },
                bannote: { permissions: ["superadmin", "admin", "srmod", "mod", "srsup", "dev", "content"], enabled: true, name: ["bannote", "bnote"] },
                logs: { permissions: ["superadmin", "admin", "srmod"], enabled: true, name: ["logs", "banhistory", "prevbans"] },
                banTemplate: { permissions: ["superadmin", "admin", "srmod", "mod", "srsup", "dev", "content"], enabled: true, name: ["bt", "tban", "bant", "bantemplate", "templateban"] },
                ban: { permissions: ["superadmin"], enabled: true, name: "pban" },
            },
            description: "Commands configuration."
        },
        { _key: "cacheBanCount", value: 30, description: "Number of bans to cache." }
    ]
};

// Handle incoming messages
window.addEventListener('message', (event) => {
    if (event.data.type === 'openConfig') {
        configName = event.data.configName;
        sortedConfig = event.data.sortedConfig;
        renderConfig();
        showConfigEditor();
    } else if (event.data.type === 'playerPosition') {
        const { x, y, z, heading } = event.data;
        const formContainer = document.querySelector('.add-form');
        if (formContainer) {
            // Update form fields with player position
            const fields = Array.from(formContainer.querySelectorAll('.form-field'));
            fields.forEach(field => field.remove());

            const newFields = [];
            const coords = [
                { key: 'x', value: x },
                { key: 'y', value: y },
                { key: 'z', value: z },
                ...(heading !== undefined ? [{ key: 'heading', value: heading }] : [])
            ];

            coords.forEach(({ key, value }) => {
                const fieldContainer = document.createElement('div');
                fieldContainer.className = 'form-field';

                const keyInput = document.createElement('input');
                keyInput.type = 'text';
                keyInput.value = key;
                fieldContainer.appendChild(keyInput);

                const valueInput = document.createElement('input');
                valueInput.type = 'text';
                valueInput.value = value;
                fieldContainer.appendChild(valueInput);

                const removeFieldButton = document.createElement('button');
                removeFieldButton.textContent = 'Remove Field';
                removeFieldButton.className = 'remove-button';
                removeFieldButton.addEventListener('click', () => {
                    fieldContainer.remove();
                    newFields.splice(newFields.indexOf(fieldContainer), 1);
                });
                fieldContainer.appendChild(removeFieldButton);

                newFields.push(fieldContainer);
                formContainer.insertBefore(fieldContainer, formContainer.querySelector('.add-button'));
            });
        } else if (indexOfLastLocationSetting !== null && lastLocationPath !== null) {
            // Update non-array location object
            const setting = sortedConfig[indexOfLastLocationSetting];
            let current = setting.value;
            const newLocation = {
                x: x,
                y: y,
                z: z,
                ...(heading !== undefined ? { heading: heading } : {})
            };

            if (lastLocationPath.length === 0) {
                // Direct location object (no nested keys)
                setting.value = newLocation;
            } else {
                // Nested location object
                for (const key of lastLocationPath.slice(0, -1)) {
                    current = current[key];
                }
                const lastKey = lastLocationPath[lastLocationPath.length - 1];
                current[lastKey] = newLocation;
            }
            renderConfig();
        }
    } else if (event.data.type === 'showConfigs') {
        renderConfigList(event.data.configs);
        showConfigList();
    }
});

// Variables for tracking non-array locations
let indexOfLastLocationSetting = null;
let lastLocationPath = null;

// Close the config editor
function closeConfigEditor() {
    configEditor.classList.add('hidden');
    document.body.classList.remove('active');
    fetch(`https://${GetParentResourceName()}/closeConfig`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(() => console.log("Fetch not available in test mode"));
}

window.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') closeConfigEditor();
});

closeButton.addEventListener('click', closeConfigEditor);

// Show config list view
function showConfigList() {
    configEditor.classList.remove('hidden');
    document.body.classList.add('active');
    document.getElementById('config-list-container').classList.remove('hidden');
    document.getElementById('config-container').classList.add('hidden');
    document.getElementById('save-button').classList.add('hidden');
    document.getElementById('config-title').textContent = 'Config List';
}

// Show config editor view
function showConfigEditor() {
    configEditor.classList.remove('hidden');
    document.body.classList.add('active');
    document.getElementById('config-list-container').classList.add('hidden');
    document.getElementById('config-container').classList.remove('hidden');
    document.getElementById('save-button').classList.remove('hidden');
    document.getElementById('config-title').textContent = 'Config Editor - ' + configName;
}

// Render config list
function renderConfigList(configs) {
    const configList = document.getElementById('config-list');
    configList.innerHTML = '';

    configs.forEach(config => {
        const li = document.createElement('li');
        li.innerHTML = `<span>${config.name} (v${config.version})</span>`;
        li.addEventListener('click', () => {
            fetch(`https://${GetParentResourceName()}/openConfig`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ configName: config.name })
            }).catch(error => console.error("Error opening config:", error));
        });
        configList.appendChild(li);
    });
}

// Render config data
function renderConfig() {
    const configTitle = document.getElementById('config-title');
    configTitle.innerHTML = 'Config Editor - ' + configName;

    const container = document.getElementById('config-container');
    container.innerHTML = '';

    sortedConfig.forEach((setting, index) => {
        const item = document.createElement('div');
        item.className = 'config-item';
        item.dataset.index = index;

        const label = document.createElement('label');
        label.textContent = setting._key;
        item.appendChild(label);

        const description = document.createElement('p');
        description.textContent = setting.description;
        item.appendChild(description);

        renderValue(setting.value, item, setting, index);
        container.appendChild(item);
    });
}

// Render values recursively
function renderValue(value, parentElement, setting, index, path = [], depth = 0) {
    if (Array.isArray(value)) {
        // Check if all elements are strings or integers
        const isSimpleArray = value.every(item => typeof item === 'string' || Number.isInteger(item));
        if (isSimpleArray) {
            const tagContainer = document.createElement('div');
            tagContainer.className = 'tag-container';

            value.forEach((item, i) => {
                const tag = document.createElement('span');
                tag.className = 'tag';
                tag.textContent = item;

                const removeTagButton = document.createElement('span');
                removeTagButton.className = 'remove-tag';
                removeTagButton.textContent = '×';
                removeTagButton.addEventListener('click', () => removeArrayItem(index, path, i));
                tag.appendChild(removeTagButton);

                tagContainer.appendChild(tag);
            });

            const input = document.createElement('input');
            input.type = 'text';
            input.placeholder = 'Add item (press Enter)';
            input.addEventListener('keydown', (event) => {
                if (event.key === 'Enter' && input.value.trim()) {
                    // Convert to integer if the array originally contains integers
                    const isIntegerArray = value.every(item => Number.isInteger(item));
                    const newValue = isIntegerArray ? parseInt(input.value) : input.value.trim();
                    if (isIntegerArray && isNaN(newValue)) {
                        console.log("Invalid integer input:", input.value);
                        return; // Skip if not a valid integer for an integer array
                    }
                    addArrayItem(index, path, newValue);
                    input.value = '';
                }
            });
            tagContainer.appendChild(input);

            parentElement.appendChild(tagContainer);
        } else {
            const arrayContainer = document.createElement('div');
            arrayContainer.className = `array-container depth-${depth}`;

            value.forEach((item, i) => {
                const itemContainer = document.createElement('div');
                itemContainer.className = 'array-item';

                const removeButton = document.createElement('button');
                removeButton.textContent = 'Remove';
                removeButton.className = 'remove-button';
                removeButton.addEventListener('click', () => removeArrayItem(index, path, i));

                renderValue(item, itemContainer, setting, index, [...path, i], depth + 1);
                itemContainer.appendChild(removeButton);
                arrayContainer.appendChild(itemContainer);
            });

            const addButton = document.createElement('button');
            addButton.textContent = 'Add Item';
            addButton.className = 'add-button';
            addButton.addEventListener('click', () => showAddItemForm(index, path, arrayContainer));
            arrayContainer.appendChild(addButton);

            const copyLastButton = document.createElement('button');
            copyLastButton.textContent = 'Copy Last';
            copyLastButton.className = 'add-button';
            copyLastButton.addEventListener('click', () => copyLastArrayItem(index, path));
            arrayContainer.appendChild(copyLastButton);

            parentElement.appendChild(arrayContainer);
        }
    } else if (typeof value === 'object' && value !== null) {
        const subContainer = document.createElement('div');
        subContainer.className = `sub-config depth-${depth}`;

        const isLocationObject = ['x', 'y', 'z'].every(key => key in value);
        if (isLocationObject) {
            subContainer.classList.add('location-object');

            const buttonContainer = document.createElement('div');
            buttonContainer.className = 'location-object-buttons';

            const teleportButton = document.createElement('button');
            teleportButton.textContent = 'Teleport to Location';
            teleportButton.className = 'teleport-button';
            teleportButton.addEventListener('click', () => {
                const location = {
                    x: value.x,
                    y: value.y,
                    z: value.z,
                    heading: value.heading
                };
                fetch(`https://${GetParentResourceName()}/teleportToPosition`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(location)
                }).catch(error => console.error("Error teleporting:", error));
            });
            buttonContainer.appendChild(teleportButton);

            const usePositionButton = document.createElement('button');
            usePositionButton.textContent = 'Use Current Position';
            usePositionButton.className = 'position-button';
            usePositionButton.addEventListener('click', () => {
                indexOfLastLocationSetting = index;
                lastLocationPath = path;
                fetch(`https://${GetParentResourceName()}/getPlayerPosition`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                })
                    .then(() => {
                        // Wait for NUI response
                    })
                    .catch(error => console.error("Error fetching position:", error));
            });
            buttonContainer.appendChild(usePositionButton);
            subContainer.appendChild(buttonContainer);
        }

        let entries = Object.entries(value);
        entries.sort((a, b) => a[0].localeCompare(b[0]));

        let fieldsContainer = subContainer;
        if (isLocationObject) {
            fieldsContainer = document.createElement('div');
            fieldsContainer.className = 'location-object-fields';
            subContainer.appendChild(fieldsContainer);
        }

        for (const [key, subValue] of entries) {
            const subItem = document.createElement('div');
            subItem.className = 'config-item sub-item';

            const subLabel = document.createElement('label');
            subLabel.textContent = key;
            subItem.appendChild(subLabel);

            renderValue(subValue, subItem, setting, index, [...path, key], depth + 1);
            fieldsContainer.appendChild(subItem);
        }

        parentElement.appendChild(subContainer);
    } else {
        let input;
        let colorPicker;
        const colorInfo = isColor(value);

        if (typeof value === 'boolean') {
            input = document.createElement('select');
            input.add(new Option('true', 'true', value === true));
            input.add(new Option('false', 'false', value === false));
            input.value = value ? 'true' : 'false';
        } else if (colorInfo) {
            const colorContainer = document.createElement('div');
            colorContainer.className = 'color-input-container';

            input = document.createElement('input');
            input.type = 'text';
            input.value = value;
            input.className = 'color-text-input';

            colorPicker = document.createElement('input');
            colorPicker.type = 'color';
            colorPicker.value = colorInfo.hex;
            colorPicker.className = 'color-picker';

            colorPicker.addEventListener('input', () => {
                let newColor = colorPicker.value;
                if (colorInfo.type === 'rgb' || colorInfo.type === 'rgba') {
                    const rgb = hexToRgb(newColor);
                    newColor = colorInfo.type === 'rgb'
                        ? `rgb(${rgb.r}, ${rgb.g}, ${rgb.b})`
                        : `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${colorInfo.alpha || 1})`;
                }
                input.value = newColor;
                validateInput(input, setting, index);
            });

            input.addEventListener('input', () => {
                const newColorInfo = isColor(input.value);
                if (newColorInfo) {
                    colorPicker.value = newColorInfo.hex;
                }
            });

            colorContainer.appendChild(input);
            colorContainer.appendChild(colorPicker);
            parentElement.appendChild(colorContainer);
        } else {
            input = document.createElement('input');
            input.type = 'text';
            input.value = value;
        }

        if (input && !colorInfo) {
            parentElement.appendChild(input);
        }

        if (input) {
            input.dataset.index = index;
            input.dataset.path = JSON.stringify(path);
            input.addEventListener('input', () => validateInput(input, setting, index));
        }
    }
}

function isColor(value) {
    if (typeof value !== 'string') return null;
    const s = value.trim();

    // Hex: #fff or #ffffff
    if (/^#([A-Fa-f0-9]{3}){1,2}$/.test(s)) {
        return { type: 'hex', hex: s.length === 4 ? '#' + s[1] + s[1] + s[2] + s[2] + s[3] + s[3] : s };
    }

    // RGB: rgb(255, 255, 255)
    const rgbMatch = s.match(/^rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)$/i);
    if (rgbMatch) {
        return {
            type: 'rgb',
            hex: rgbToHex(parseInt(rgbMatch[1]), parseInt(rgbMatch[2]), parseInt(rgbMatch[3]))
        };
    }

    // RGBA: rgba(255, 255, 255, 0.5)
    const rgbaMatch = s.match(/^rgba\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+)\s*\)$/i);
    if (rgbaMatch) {
        return {
            type: 'rgba',
            hex: rgbToHex(parseInt(rgbaMatch[1]), parseInt(rgbaMatch[2]), parseInt(rgbaMatch[3])),
            alpha: rgbaMatch[4]
        };
    }

    return null;
}

function rgbToHex(r, g, b) {
    return "#" + [r, g, b].map(x => {
        const hex = Math.max(0, Math.min(255, x)).toString(16);
        return hex.length === 1 ? "0" + hex : hex;
    }).join("");
}

function hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}

// New function to copy the last array item
function copyLastArrayItem(index, path) {
    const setting = sortedConfig[index];
    let current = setting.value;

    for (const key of path.slice(0, -1)) {
        current = current[key];
    }
    const lastKey = path[path.length - 1];
    const array = lastKey === undefined ? current : current[lastKey];

    if (array.length === 0) {
        console.log("No items to copy in array");
        return; // Nothing to copy if array is empty
    }

    // Deep copy the last item to avoid reference issues
    const lastItem = JSON.parse(JSON.stringify(array[array.length - 1]));
    array.push(lastItem);

    renderConfig();
}

// Show form for adding new array items
function showAddItemForm(index, path, arrayContainer) {
    const formContainer = document.createElement('div');
    formContainer.className = 'add-form';

    const fields = [];
    const addField = () => {
        const fieldContainer = document.createElement('div');
        fieldContainer.className = 'form-field';

        const keyInput = document.createElement('input');
        keyInput.type = 'text';
        keyInput.placeholder = 'Key (optional, e.g., x)';
        fieldContainer.appendChild(keyInput);

        const valueInput = document.createElement('input');
        valueInput.type = 'text';
        valueInput.placeholder = 'Value (e.g., superadmin)';
        fieldContainer.appendChild(valueInput);

        const removeFieldButton = document.createElement('button');
        removeFieldButton.textContent = 'Remove Field';
        removeFieldButton.className = 'remove-button';
        removeFieldButton.addEventListener('click', () => {
            fieldContainer.remove();
            fields.splice(fields.indexOf(fieldContainer), 1);
        });
        fieldContainer.appendChild(removeFieldButton);

        fields.push(fieldContainer);
        formContainer.appendChild(fieldContainer);
    };

    const addFieldButton = document.createElement('button');
    addFieldButton.textContent = 'Add Field';
    addFieldButton.className = 'add-button';
    addFieldButton.addEventListener('click', addField);
    formContainer.appendChild(addFieldButton);

    const setting = sortedConfig[index];
    let current = setting.value;
    for (const key of path.slice(0, -1)) {
        current = current[key];
    }
    const lastKey = path[path.length - 1];
    const array = lastKey === undefined ? current : current[lastKey];
    const isLocationArray = array.length > 0 && typeof array[0] === 'object' &&
        ['x', 'y', 'z'].every(key => key in array[0]);

    if (isLocationArray) {
        const buttonContainer = document.createElement('div');
        buttonContainer.className = 'location-object-buttons';
        buttonContainer.style.justifyContent = 'center';
        buttonContainer.style.marginBottom = '10px';

        const teleportButton = document.createElement('button');
        teleportButton.textContent = 'Teleport to Location';
        teleportButton.className = 'teleport-button';
        teleportButton.addEventListener('click', () => {
            const firstLocation = array[0];
            const location = {
                x: firstLocation.x,
                y: firstLocation.y,
                z: firstLocation.z,
                heading: firstLocation.heading
            };
            fetch(`https://${GetParentResourceName()}/teleportToPosition`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(location)
            }).catch(error => console.error("Error teleporting:", error));
        });
        buttonContainer.appendChild(teleportButton);

        const usePositionButton = document.createElement('button');
        usePositionButton.textContent = 'Use Current Position';
        usePositionButton.className = 'position-button';
        usePositionButton.addEventListener('click', () => {
            fetch(`https://${GetParentResourceName()}/getPlayerPosition`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            })
                .then(() => {
                    // Wait for NUI response
                })
                .catch(error => console.error("Error fetching position:", error));
        });
        buttonContainer.appendChild(usePositionButton);
        formContainer.appendChild(buttonContainer);
    }

    const submitButton = document.createElement('button');
    submitButton.textContent = 'Submit';
    submitButton.className = 'submit-button';
    submitButton.addEventListener('click', () => {
        let newItem;
        const hasContent = fields.some(field => {
            const keyInput = field.querySelector('input[type="text"]:nth-child(1)').value;
            const valueInput = field.querySelector('input[type="text"]:nth-child(2)').value;
            return keyInput || valueInput;
        });

        if (!hasContent) {
            fields.forEach(field => {
                const keyInput = field.querySelector('input[type="text"]:nth-child(1)');
                const valueInput = field.querySelector('input[type="text"]:nth-child(2)');
                if (!keyInput.value && !valueInput.value) {
                    keyInput.classList.add('invalid');
                    valueInput.classList.add('invalid');
                }
            });
            return;
        }

        fields.forEach(field => {
            field.querySelector('input[type="text"]:nth-child(1)').classList.remove('invalid');
            field.querySelector('input[type="text"]:nth-child(2)').classList.remove('invalid');
        });

        if (fields.length === 1 && !fields[0].querySelector('input[type="text"]:nth-child(1)').value) {
            newItem = fields[0].querySelector('input[type="text"]:nth-child(2)').value || "";
        } else {
            newItem = {};
            fields.forEach(field => {
                const keyInput = field.querySelector('input[type="text"]:nth-child(1)');
                const valueInput = field.querySelector('input[type="text"]:nth-child(2)');
                if (keyInput.value) {
                    newItem[keyInput.value] = valueInput.value || "";
                }
            });
            if (Object.keys(newItem).length === 0 && fields.length > 0) {
                newItem = fields[0].querySelector('input[type="text"]:nth-child(2)').value || "";
            }
        }

        addArrayItem(index, path, newItem);
        formContainer.remove();
    });
    formContainer.appendChild(submitButton);

    // Add initial field
    addField();

    arrayContainer.appendChild(formContainer);
}

// Add item to array
function addArrayItem(index, path, newItem) {
    const setting = sortedConfig[index];
    let current = setting.value;

    for (const key of path.slice(0, -1)) {
        current = current[key];
    }
    const lastKey = path[path.length - 1];

    const array = lastKey === undefined ? current : current[lastKey];
    array.push(newItem);

    renderConfig();
}

// Remove item from array
function removeArrayItem(index, path, itemIndex) {
    const setting = sortedConfig[index];
    let current = setting.value;

    for (const key of path.slice(0, -1)) {
        current = current[key];
    }
    const lastKey = path[path.length - 1];

    const array = lastKey === undefined ? current : current[lastKey];
    array.splice(itemIndex, 1);

    renderConfig();
}

// Validate input changes
function validateInput(input, setting, index) {
    const path = JSON.parse(input.dataset.path || '[]');
    let current = setting.value;

    // Navigate to the correct level in the object
    for (const key of path.slice(0, -1)) {
        current = current[key];
    }
    const lastKey = path[path.length - 1];

    // Determine the new value based on input type
    let newValue;
    if (input.tagName === 'SELECT') {
        newValue = input.value === 'true'; // Convert "true"/"false" string to boolean
    } else {
        // For text inputs, try to infer the correct type based on the original value
        const originalValue = lastKey ? current[lastKey] : setting.value;
        if (typeof originalValue === 'boolean') {
            newValue = input.value.toLowerCase() === 'true';
        } else if (typeof originalValue === 'number') {
            newValue = isNaN(parseFloat(input.value)) ? input.value : parseFloat(input.value);
        } else {
            newValue = input.value; // Keep as string for text
        }
    }

    // Apply the new value
    if (path.length === 0) {
        // Direct value (no nesting)
        sortedConfig[index].value = newValue;
    } else {
        // Nested value
        current[lastKey] = newValue;
    }

    console.log("Validated input:", { index, path, newValue, updatedConfig: sortedConfig[index].value });
    input.classList.remove('invalid');
}

// Save changes
document.getElementById('save-button').addEventListener('click', () => {
    const inputs = document.querySelectorAll('#config-container input, #config-container select');
    let hasErrors = false;

    inputs.forEach(input => {
        const index = input.dataset.index;
        if (index === undefined || index === null) {
            console.log("Skipping input with undefined index:", input);
            return; // Skip inputs without a valid index
        }
        const setting = sortedConfig[index];
        if (setting) {
            validateInput(input, setting, index); // Validate and update the config
        } else {
            console.log("Could not validate input for index:", index, input);
            hasErrors = true; // Mark as error if setting is undefined
        }
    });

    if (hasErrors) return;

    console.log("Saving config:", JSON.stringify({ configName, sortedConfig }, null, 2));

    fetch(`https://${GetParentResourceName()}/saveConfig`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            type: 'saveConfig',
            configName: configName,
            sortedConfig
        })
    }).catch(() => console.log("Config saved locally (test mode):", JSON.stringify(sortedConfig, null, 2)));

    closeConfigEditor();
});

// Load default config on page load
document.addEventListener('DOMContentLoaded', () => {
    if(!loadDefaultConfig) return;
    configName = defaultConfig.configName;
    sortedConfig = defaultConfig.sortedConfig;
    renderConfig();
    showConfigEditor();
});