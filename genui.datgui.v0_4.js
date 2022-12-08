

const addProp = (gui, prop, state, actions, update) => {
    const def = prop.def;
    const property = prop.property || prop.name;
    const name = prop.name || prop.property;
    let control;
    switch (prop.kind) {
        case 'select': case 'choice':
            state[property] = def.current;
            const values = def.values.map((v) => /* v.name ||*/ v.value); // FIXME: should send value to `update`, but use `name`
            control = gui.add(state, property, values).name(name).onFinishChange((val) => { update(property, val); });
            if (prop.live) { control.live(); }
            return { property, control, values : def.values };
        case 'float': case 'int': // FIXME: add zoom
            state[property] = def.current;
            control = gui.add(state, property, def.min, def.max, def.step).name(name).onFinishChange((val) => { update(property, val); });
            if (prop.live) { control.live(); }
            return { property, control };
        case 'text':
            state[property] = def.current;
            control = gui.add(state, property).name(name).onFinishChange((val) => { update(property, val); });
            if (prop.live) { control.live(); }
            return { property, control };
        case 'color':
            state[property] = def.current;
            control = gui.addColor(state, property).name(name).onFinishChange((val) => { update(property, val); });
            if (prop.live) { control.live(); }
            return { property, control };
        case 'toggle':
            state[property] = def.current;
            control = gui.add(state, property).name(name).onFinishChange((val) => { update(property, val); });
            if (prop.live) { control.live(); }
            return { property, control };
        case 'nest':
            const nestFolder = gui.addFolder(name);
            const pre_mapping = prop.def.children.map(childProp => addProp(nestFolder, childProp, def.nest ? state[def.nest] : state, actions, update));
            if (def.expand) {
                nestFolder.open();
            }
            control = nestFolder;
            let mapping = {}
            pre_mapping.forEach((p) => {
                if (p) {
                    mapping[p.property] = { control : p.control };
                }
            });
            return { property, control, children : mapping };
        case 'action': case 'progress': case 'gradient':
            if (actions) {
                if (actions.hasOwnProperty(property)) {
                    control = gui.add(actions, property).name(name);
                    return { property, control };
                } else if (typeof actions === 'function') {
                    let customHandler = {};
                    customHandler[property] = () => { actions(property); }
                    control = gui.add(customHandler, property).name(name);
                    return { property, control, handler : customHandler };
                } else {
                    console.warn('actions object doesn\'t have handler for ' + property + ', or not a function');
                }
            } else {
                if (state.hasOwnProperty(property)) {
                    control = gui.add(state, property).name(name);
                    return { property, control };
                } else {
                    console.warn('state object doesn\'t have handler for ' + property);
                }
            }
            break;
        case 'xy':
            const xyFolder = gui.addFolder(name);
            state[property]['x'] = def.x.current;
            state[property]['y'] = def.y.current;
            const x = xyFolder.add(state[property], 'x', def.x.min, def.x.max, def.x.step).name(name).onFinishChange((val) => { update(property, { x: val }); });
            const y = xyFolder.add(state[property], 'y', def.y.min, def.y.max, def.y.step).name(name).onFinishChange((val) => { update(property, { y: val }); });
            control = xyFolder;
            if (prop.live) { x.control.live(); }
            if (prop.live) { y.control.live(); }
            return { property, control, children : { x : { control : x.control }, y : { control : y.control } } };
        // TODO: progress, gradient
        default:
            console.warn('property was not handled, because of its unsupported kind', prop.kind, property);
            break;
    }
}

const GenUI = {}

GenUI.REF = '__dat_gui';

GenUI.toDatGUI = (genui, state, actions, update) => {
    const gui = new dat.GUI();
    console.log('Gen UI, version ', genui.version);
    const pre_mapping = genui.root.map(prop => addProp(gui, prop, state, actions, update));
    let mapping = {}
    pre_mapping.forEach((p) => {
        if (p) {
            mapping[p.property] = { control : p.control, children : p.children };
        }
    });
    mapping[GenUI.REF] = gui;
    return mapping;
};

GenUI.toDatGUI_ = (root, state, update) => {
    GenUI.toDatGUI(root, state, state, update);
};

GenUI.getDatGUI = (mapping) => {
    if (!mapping) {
        console.error('cannot load dat.gui without GenUI instance');
        return;
    }
    return mapping[GenUI.REF];
}

const loadPropPath = (prop) => {
    console.log('statePath', prop.statePath);
    if (prop.statePath) { return prop.statePath; }
    if (prop.property) { return [ prop.property ]; }
    if (prop.name) { return [ prop.name ]; }
}

const loadPropId = (prop) => {
    return prop.property || prop.name;
}

const valueAtPath = (src, path) => {
    if (!path.length) return null;
    if (path.length > 1) {
        return valueAtPath(src.hasOwnProperty(path[0]) ? src[path[0]] : {}, path.slice(1));
    } else {
        return src.hasOwnProperty(path[0]) ? src[path[0]] : null;
    }
}

const assignAtPath = (path, accum, what, where) => {
    let focus = where || accum || {};
    if (path.length > 0) {
        let nextPath = path.slice(1);
        if (nextPath.length > 0) {
            if (focus.hasOwnProperty(path[0])) {
                assignAtPath(nextPath, accum, what, focus[path[0]]);
            } else {
                focus[path[0]] = {};
                assignAtPath(nextPath, accum, what, focus[path[0]]);
            }
        } else {
            focus[path[0]] = what;
        }

    };
}

GenUI.export = (root, state, target, useStatePaths = false) => { // always with useStatePaths?
    return root.reduce(
        (accum, prop) => {
            const propId = loadPropId(prop);
            if (prop.kind != 'action') {
                if (useStatePaths) {
                    if (prop.kind != 'nest') {
                        const propPath = loadPropPath(prop);
                        assignAtPath(propPath, accum, state.hasOwnProperty(propId) ? state[propId] : prop.def.current);
                    } else {
                        window.GenUI.export(prop.def.children, state, accum, useStatePaths);
                    }
                } else {
                    if (prop.kind != 'nest') {
                        accum[propId] = state.hasOwnProperty(propId) ? state[propId] : prop.def.current;
                    } else {
                        accum[propId] = window.GenUI.export(prop.def.children, state, accum, useStatePaths);
                    }
                }
            }
            return accum;
        },
        target || {}
    );
}


GenUI.load = (root, from, target, withStatePaths = false) => { // always with withStatePaths?
    return root.reduce(
        (accum, prop) => {
            const propId = loadPropId(prop);
            if (prop.kind != 'action') {
                if (withStatePaths) {
                    if (prop.kind != 'nest') {
                        const propPath = loadPropPath(prop);
                        state[propId] = valueAtPath(from, propPath);
                        //assignAtPath(propPath, accum, state.hasOwnProperty(propId) ? state[propId] : prop.def.current);
                    } else {
                        // window.GenUI.toState(prop.def.children, state, accum, useMapping);
                        window.GenUI.load(prop.def.children, from, accum, withStatePaths)
                    }
                } else {
                    state[propId] = from[propId];
                }
            }
            return accum;
        },
        target || {}
    );
}

// TODO: support statePath and triggerOn

window.GenUI = GenUI;