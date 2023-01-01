import { context, Node, queueUpdate, queueUpdateBecausePreviousUsagesMightBeStale, } from './core.js';
import { text } from './text.js';
import { beginWrapper, endWrapper } from './child.js';
class SliderFloatNode extends Node {
    #inputElem;
    #value;
    #haveNewValue = false;
    #min;
    #max;
    constructor() {
        super('input');
        this.#inputElem = this.elem;
        this.#inputElem.type = 'range';
        this.#inputElem.addEventListener('input', (e) => {
            this.#value = parseFloat(this.#inputElem.value);
            this.#haveNewValue = true;
            queueUpdate();
        });
    }
    update(value, min, max) {
        if (this.#haveNewValue) {
            this.#haveNewValue = false;
            value = this.#value;
            queueUpdateBecausePreviousUsagesMightBeStale();
        }
        else {
            if (value !== this.#value) {
                this.#value = value;
                this.#inputElem.value = value.toString();
            }
        }
        if (min !== this.#min) {
            this.#min = min;
            this.#inputElem.min = min.toString();
            this.#inputElem.step = ((this.#max - this.#min) / 1000).toString();
        }
        if (max !== this.#max) {
            this.#max = max;
            this.#inputElem.max = max.toString();
            this.#inputElem.step = ((this.#max - this.#min) / 1000).toString();
        }
        return value;
    }
}
export function sliderFloatNode(value, min = 0, max = 1) {
    const node = context.getExistingNodeOrRemove(SliderFloatNode);
    return node.update(value, min, max);
}
export function sliderFloat(prompt, value, min = 0, max = 1) {
    beginWrapper('slider-float form-line');
    beginWrapper('slider-value');
    value = sliderFloatNode(value, min, max);
    text(value.toFixed(2));
    endWrapper();
    text(prompt);
    endWrapper();
    return value;
}
