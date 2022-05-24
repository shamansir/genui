

const addProp = (gui, prop, state, actions, update) => {
    const def = prop.def;
    const property = prop.property || prop.name;
    const name = prop.name || prop.property;
    switch (prop.kind) {
        case 'select':
            state[property] = def.current;
            gui.add(state, property, def.values).name(name).onFinishChange((val) => { update(property, val); });
            // TODO: love
            break;
        case 'float': case 'int':
            state[property] = def.current;
            gui.add(state, property, def.min, def.max, def.step).name(name).onFinishChange((val) => { update(property, val); });
            break;
        case 'text': case 'color':
            state[property] = def.current;
            gui.add(state, property).name(name).onFinishChange((val) => { update(property, val); });
            break;
        case 'toggle':
            state[property] = def.current;
            gui.add(state, property).name(name).onFinishChange((val) => { update(property, val); });
            break;
        case 'nest':
            const nestFolder = gui.addFolder(name);
            prop.def.children.forEach(childProp => {
                addProp(nestFolder, childProp, def.nest ? state[def.nest] : state, actions, update);
            });
            if (def.expand) {
                nestFolder.open();
            }
            break;
        case 'action':
            if (actions.hasOwnProperty(property)) {
                gui.add(actions, property).name(name);
            } else {
                console.warn('actions object doesn\'t have handler for ' + property);
            }
            break;
        case 'xy':
            const xyFolder = gui.addFolder(name);
            state[property]['x'] = def.x.current;
            state[property]['y'] = def.y.current;
            xyFolder.add(state[property], 'x', def.x.min, def.x.max, def.x.step).name(name).onFinishChange((val) => { update(property, { x: val }); });
            xyFolder.add(state[property], 'y', def.y.min, def.y.max, def.y.step).name(name).onFinishChange((val) => { update(property, { y: val }); });
            break;
        default:
            console.warn('property was not handled, because of its unsupported kind', prop.kind, property);
            break;
    }
}

const GenUI = {}

GenUI.toDatGUI = (root, state, actions, update) => {
    const gui = new dat.GUI();
    root.forEach(prop => {
        addProp(gui, prop, state, actions, update);
    });
};

GenUI.toDatGUI_ = (root, state, update) => {
    GenUI.toDatGUI(root, state, state, update);
};

window.GenUI = GenUI;