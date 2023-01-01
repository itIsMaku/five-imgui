import { Node, queueUpdate, context } from './core.js';
class ButtonNode extends Node {
    #result = false;
    #prompt;
    constructor(str) {
        super('button');
        this.elem.addEventListener('click', () => {
            this.#result = true;
            queueUpdate();
        });
    }
    update(str) {
        if (this.#prompt !== str) {
            this.#prompt = str;
            this.elem.textContent = str;
        }
        const result = this.#result;
        this.#result = false;
        return result;
    }
}
export function button(str) {
    const button = context.getExistingNodeOrRemove(ButtonNode, str);
    return button.update(str);
}
