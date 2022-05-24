const readJsonGui = (name, cb) => {
    fetch(`http://localhost:8005/${name}.json`)
        .then(response => {
            if (!response.ok) {
                throw new Error("HTTP error " + response.status);
            }
            return response.json();
        })
        .then((json) => cb(null, json))
        .catch((err) => cb(err, null));
};

const addProp = (gui, prop, state, actions, update) => {
    const def = prop.def;
    const property = prop.property || prop.name;
    const name = prop.name || prop.property;
    switch (prop.kind) {
        case 'select':
            state[property] = prop.def.current;
            gui.add(state, property, def.values).name(name).onFinishChange((val) => { update(property, val); });
            break;
        case 'float': case 'int':
            state[property] = prop.def.current;
            gui.add(state, property, def.min, prop.def.max, prop.def.step).name(name).onFinishChange((val) => { update(property, val); });
            break;
        case 'text':
            state[property] = prop.def.current;
            gui.add(state, property).name(name).onFinishChange((val) => { update(property, val); });
            break;
        case 'toggle':
            state[property] = prop.def.current;
            gui.add(state, property).name(name).onFinishChange((val) => { update(property, val); });
            break;
        case 'nest':
            const nestFolder = gui.addFolder(name);
            prop.def.children.forEach(childProp => {
                addProp(nestFolder, childProp, state, actions, update);
            });
            break;
        case 'action':
            if (actions.hasOwnProperty(property)) {
                gui.add(actions, property).name(name);
            } else {
                console.warn('actions object doesn\'t have handler for ' + property);
            }
            break;
        // TODO: xy, color
        default:
            break;
    }
}

const buildGui = (root, state, actions, update) => {
    const gui = new dat.GUI();
    root.forEach(prop => {
        addProp(gui, prop, state, actions, update);
    });
};


readJsonGui('gradient',
    (err, json) =>
        {
            if (err) {
                console.error(err);
                return;
            }
            let state = {};
            let actions = {};
            const update =
                (prop, val) => {
                    console.log(prop, val);
                };
            buildGui(json, state, actions, update);
        }
);