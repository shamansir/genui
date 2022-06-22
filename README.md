# GenUI

GenUI means _Generative User Interface (Definition)_. It appeared from thought that many controls for generative graphics and art, which we produce at [CAI](https://cai.jetbrains.com/), have a similar number of common inputs (number, text, color, X/Y, etc.), and this kind of UI commonly has such inputs grouped in folders. So we decided that may be we may abstract from visual representation of those and define their properties in some unified way. It provides us with the ability to switch between many implementations, such as `dat.gui` or [Tron](https://github.com/shamansir/tron-gui) and to switch between specific sets of controls as well (i.e. a set for development and a set for production).

The definition is very minimal and presented in both [`DHALL`](https://dhall-lang.org/) and [`Elm`](https://elm-lang.org/) languages, yet for the moment they are not checked in terms that they produce the same result.

For an example of such definition, see [`gradient.dhall`](https://github.com/shamansir/genui/blob/main/gui/gradient.dhall).

`DHALL` version may produce `JSON` and `YAML` representations.

`Elm` version may:

* Produce
    * `JSON` definition;
    * `YAML` definition;
    * _Descriptive_ definition;
    * (soon) `DHALL` definition;
    * A graph of controls with folders as branches and controls as nodes;
* Parse
    * `JSON` definition;
    * `YAML` definition;

The JSON variant is considered as the specification of the language schema. Also, [JSON schema](https://json-schema.org/) soon to be added to test the produced definitions on similarity.

# Generate example

Install `dhall-to-json` and `dhall-to-yaml`. ([How to install](https://docs.dhall-lang.org/tutorials/Getting-started_Generate-JSON-or-YAML.html#installation))

And run:

```bash
sh ./generate-yaml.sh gradient
sh ./generate-json.sh gradient
```

# Demo

Run `elm reactor` in the cloned repository and open `src/Demo.elm`. Copy and paste a JSON there.