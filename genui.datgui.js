

const addProp = (gui, prop, state, actions, update) => {
    const def = prop.def;
    const property = prop.property || prop.name;
    const name = prop.name || prop.property;
    let control;
    switch (prop.kind) {
        case 'select':
            state[property] = def.current;
            control = gui.add(state, property, def.values).name(name).onFinishChange((val) => { update(property, val); });
            return { property, control };
        case 'float': case 'int':
            state[property] = def.current;
            control = gui.add(state, property, def.min, def.max, def.step).name(name).onFinishChange((val) => { update(property, val); });
            return { property, control };
        case 'text': case 'color':
            state[property] = def.current;
            control = gui.add(state, property).name(name).onFinishChange((val) => { update(property, val); });
            return { property, control };
        case 'toggle':
            state[property] = def.current;
            control = gui.add(state, property).name(name).onFinishChange((val) => { update(property, val); });
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
        case 'action':
            if (actions.hasOwnProperty(property)) {
                control = gui.add(actions, property).name(name);
                return { property, control };
            } else {
                console.warn('actions object doesn\'t have handler for ' + property);
            }
            break;
        case 'xy':
            const xyFolder = gui.addFolder(name);
            state[property]['x'] = def.x.current;
            state[property]['y'] = def.y.current;
            const x = xyFolder.add(state[property], 'x', def.x.min, def.x.max, def.x.step).name(name).onFinishChange((val) => { update(property, { x: val }); });
            const y = xyFolder.add(state[property], 'y', def.y.min, def.y.max, def.y.step).name(name).onFinishChange((val) => { update(property, { y: val }); });
            control = xyFolder;
            return { property, control, children : { x : { control : x.control }, y : { control : y.control } } };
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

window.GenUI = GenUI;