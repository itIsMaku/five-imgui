import { Node, queueUpdate, context } from './core.js';
class ButtonNode extends Node {
    #result = false;
    constructor(defaultValue) {
        super('button');
        this.#result = defaultValue;
        this.elem.innerHTML = getText(defaultValue);
        this.elem.addEventListener('click', () => {
            this.#result = !this.#result;
            this.elem.innerHTML = getText(this.#result);
            queueUpdate();
        });
    }
    update() {
        return this.#result;
    }
}
export function switchButton(defaultValue) {
    const button = context.getExistingNodeOrRemove(ButtonNode, defaultValue);
    return button.update();
}

function getText(result) {
    if (result) {
        return '✖';
    } else {
        return '&nbsp;';
    }
}