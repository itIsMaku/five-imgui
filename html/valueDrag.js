import { clamp, } from './utils.js';
import { context, Node, queueUpdate, queueUpdateBecausePreviousUsagesMightBeStale, } from './core.js';
class ValueDragNode extends Node {
    #prompt;
    #startValue;
    #value;
    #min = 0;
    #max = 0;
    #precision = 2;
    #haveNewValue = false;
    #mouseStartX;
    #moveRange = 100;
    constructor(prompt, value, min = 0, max = 1, precision = 2) {
        super('div');
        this.setClassName('value-drag');
        this.elem.addEventListener('mousedown', (e) => {
            this.#mouseStartX = e.clientX;
            this.#startValue = this.#value;
            window.addEventListener('mousemove', this.#onMouseMove);
            window.addEventListener('mouseup', this.#onMouseUp);
        });
    }
    #onMouseMove = (e) => {
        const deltaNorm = (e.clientX - this.#mouseStartX) / this.#moveRange;
        const delta = (this.#max - this.#min) * deltaNorm;
        const newValue = clamp(this.#startValue + delta, this.#min, this.#max);
        this.#value = newValue;
        this.#haveNewValue = true;
        this._update();
        queueUpdate();
    };
    #onMouseUp = () => {
        window.removeEventListener('mousemove', this.#onMouseMove);
        window.removeEventListener('mouseup', this.#onMouseUp);
    };
    _update() {
        this.elem.textContent = `${this.#prompt}${this.#value.toFixed(this.#precision)}`;
    }
    update(prompt, value, min = 0, max = 1, precision = 2) {
        if (this.#haveNewValue) {
            this.#haveNewValue = false;
            value = this.#value;
            queueUpdateBecausePreviousUsagesMightBeStale();
        }
        else {
            if (value !== this.#value ||
                prompt !== this.#prompt ||
                min !== this.#min ||
                max !== this.#max ||
                precision !== this.#precision) {
                this.#value = clamp(value, min, max);
                this.#prompt = prompt;
                this.#min = min;
                this.#max = max;
                this.#precision = precision;
                this._update();
            }
        }
        return value;
    }
}
export function valueDrag(prompt, value, min = 0, max = 1, precision = 2) {
    const node = context.getExistingNodeOrRemove(ValueDragNode, value, min, max);
    return node.update(prompt, value, min, max);
}
