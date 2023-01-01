import { Node, Context, context } from './core.js';
export class BasicWrapperNode extends Node {
    #context;
    constructor() {
        super('div');
        this.#context = new Context(this.elem, this.end);
    }
    begin(className) {
        this.setClassName(className);
        Context.pushContext(this.#context);
    }
    end = () => {
        Context.popContext();
    };
}
export function beginWrapper(className) {
    const node = context.getExistingNodeOrRemove(BasicWrapperNode);
    node.begin(className);
}
export function endWrapper() {
    context.finish();
}
export function beginChild(id) {
    beginWrapper('child layout-scrollbar');
}
export function endChild() {
    endWrapper();
}
