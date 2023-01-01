import { queueUpdate } from './core.js';
import * as ImHUI from './ImHUI.js';

const guis = {
    /*'imhuitest': {
        id: 'imhuitest',
        settings: { title: 'ImHUI Test', active: true },
        content: [
            { id: 'test', method: 'sliderFloat', value: 'Test slideru', defaultValue: 1, data: [0, 15] },
            { id: 'sepa', method: 'separator' },
            { id: 'test2', method: 'inputText', value: 'Test input textu', defaultValue: 'Input' }
        ],
        data: {
            'test': 0,
            'sepa': 0,
            'test2': 0
        }
    }*/
};

function getGuiElementIndexByElementId(array, element) {
    for (let i = 0; i < array.length; i++) {
        const v = array[i];
        if (v.id == element) {
            return i
        }
    }
    return -1;
}

window.addEventListener('message', (event) => {
    let type = event.data.type;
    let gui = event.data.gui;
    if (type === 'create') {
        if (guis.hasOwnProperty(gui.id)) {
            console.log(`Gui id ${gui.id} already exists!`)
            return;
        }
        let data = {}
        for (let i = 0; i < gui.content.length; i++) {
            const element = gui.content[i];
            if (element.defaultValue === undefined) {
                element.defaultValue = 0;
            }
            data[element.id] = element.defaultValue;
        }
        gui.data = data;
        guis[gui.id] = gui;
    } else if (type === 'update') {
        for (let i = 0; i < gui.content.length; i++) {
            const element = gui.content[i];
            const index = getGuiElementIndexByElementId(guis[gui.id].content, element.id);
            if (index != -1) {
                guis[gui.id].content[index] = element;
            } else {
                guis[gui.id].content.push(element);
            }
            guis[gui.id].data[element.id] = element.defaultValue;
        }
    } else if (type === 'destroy') {
        destroy(gui.id);
    }
});

function createUI(gui) {
    ImHUI.begin(gui.settings);
    for (let i = 0; i < gui.content.length; i++) {
        const element = gui.content[i];
        //console.log(guis[gui.id].data[element.id]);
        if (element.data === undefined) {
            element.data = [];
        }
        let value;
        if (element.data[0] != 'json') {
            value = ImHUI[element.method](element.value, guis[gui.id].data[element.id], element.data[0], element.data[1]);
        }
        if (element.method != 'plotLines' && element.method != 'textColored' && element.method != 'button' && element.method != 'switchButton' && element.method != 'text') {
            guis[gui.id].data[element.id] = value;
        }
        if ((element.method == 'button') && value) {
            fetch(`https://${GetParentResourceName()}/clickedButton`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    guiId: gui.id,
                    elementId: element.id,
                    event: guis[gui.id].data[element.id],
                    elementsData: guis[gui.id].data
                })
            });
        }
        if (element.method == 'switchButton' && (guis[gui.id].data[element.id] != value)) {
            console.log(value);
            guis[gui.id].data[element.id] = value;
            fetch(`https://${GetParentResourceName()}/clickedSwitchButton`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    guiId: gui.id,
                    elementId: element.id,
                    event: element.data[0],
                    state: value
                })
            });
        }
        if (element.method == 'text' && element.data[0] == 'json' && !guis[gui.id].data[element.id]) {
            guis[gui.id].data[element.id] = true
            const container = document.getElementById(gui.settings.id).getElementsByTagName('details');
            const textBox = document.createElement("pre");
            textBox.setAttribute("id", "formatted-text-" + element.id);
            if (element.data[1] == 'childstyle') {
                textBox.className = ('child layout-scrollbar');
            }
            container[0].append(textBox);
            document.getElementById("formatted-text-" + element.id).innerHTML = element.value;
        }
    }
    if (ImHUI.button('✖')) {
        destroy(gui.id);
    }
    ImHUI.end();
}

function destroy(id) {
    fetch(`https://${GetParentResourceName()}/windowClosed`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            guiId: id,
            elementsData: guis[id].data
        })
    });
    let root = document.getElementById("root");
    let id2 = document.getElementById(id);
    root.removeChild(id2);
    let settings = guis[id].settings;
    ImHUI.destroy(settings);
    delete guis[id];
    /*fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        }
    }); */
}

function renderUI() {
    ImHUI.start();
    let keys = Object.keys(guis);
    for (let i = 0; i < keys.length; i++) {
        const gui = guis[keys[i]];
        createUI(gui);
    }
    ImHUI.finish();
}

ImHUI.setup(document.querySelector('#root'), renderUI);

let fps = 0;
let then = 0;

function render(now) {
    const elapsedTime = now - then;
    fps = 1000 / elapsedTime;
    then = now;
    queueUpdate();
    requestAnimationFrame(render);
}
requestAnimationFrame(render);