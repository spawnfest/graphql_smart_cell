import "https://unpkg.com/react@17.0.2/umd/react.development.js"
import "https://unpkg.com/react-dom@17.0.2/umd/react-dom.development.js"
import "https://unpkg.com/graphiql@2.0.9/graphiql.min.js"
import * as Vue from "https://cdn.jsdelivr.net/npm/vue@3.2.26/dist/vue.esm-browser.prod.js";


export function init(ctx, payload) {
  console.log("editor_cell.init", ctx, payload);
  let form_element = document.createElement("div")
  let graphiql_element = document.createElement("div")
  ctx.root.appendChild(form_element)
  ctx.root.appendChild(graphiql_element)
  form_init(ctx, payload, form_element)
  // graphiql_init(ctx, payload, graphiql_element)
}

function graphiql_init(ctx, payload, root) {

  ctx.importCSS(
    "https://fonts.googleapis.com/css2?family=Inter:wght@400;500&display=swap"
  );
  ctx.importCSS(
    "https://unpkg.com/graphiql/graphiql.min.css"
  );

  ctx.importCSS("main.css");

  const fetcher = GraphiQL.createFetcher({
    url: "https://rickandmortyapi.com/graphql"
  });


  ReactDOM.render(
    React.createElement(
      GraphiQL.React.GraphiQLProvider, {
      fetcher: fetcher
    },
      React.createElement(
        "div", {
        className: "graphiql-container"
      },
        React.createElement(
          "div", {
          className: "graphiql-query-editor"
        },
          React.createElement(
            "div", {
            className: "graphiql-query-editor-wrapper"
          },
            React.createElement(GraphiQL.React.QueryEditor, {
              value: payload.query || "query { name }",
              onEdit: function (query) {
                ctx.pushEvent("update_query", {
                  query
                });
              },
            }))
        ))
    ),
    root
  )
}

function form_init(ctx, payload, root) {
  ctx.importCSS("main.css");
  ctx.importCSS(
    "https://fonts.googleapis.com/css2?family=Inter:wght@400;500&display=swap"
  );
  ctx.importCSS(
    "https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.min.css"
  );

  const BaseSelect = {
    name: "BaseSelect",

    props: {
      label: {
        type: String,
        default: "",
      },
      selectClass: {
        type: String,
        default: "input",
      },
      modelValue: {
        type: String,
        default: "",
      },
      options: {
        type: Array,
        default: [],
        required: true,
      },
      required: {
        type: Boolean,
        default: false,
      },
      inline: {
        type: Boolean,
        default: false,
      },
      existent: {
        type: Boolean,
        default: false,
      },
      disabled: {
        type: Boolean,
        default: false,
      },
    },

    template: `
    <div v-bind:class="inline ? 'inline-field' : 'field'">
      <label v-bind:class="inline ? 'inline-input-label' : 'input-label'">
        {{ label }}
      </label>
      <select
        :value="modelValue"
        v-bind="$attrs"
        v-bind:disabled="disabled"
        @change="$emit('update:data', $event.target.value)"
        v-bind:class="[selectClass, existent ? '' : 'nonexistent']"
      >
        <option
          v-for="option in options"
          :value="option.value"
          :key="option"
          :selected="option.value === modelValue"
        >{{ option.label }}</option>
      </select>
    </div>
    `,
  };

  const BaseInput = {
    name: "BaseInput",

    props: {
      label: {
        type: String,
        default: "",
      },
      inputClass: {
        type: String,
        default: "input",
      },
      modelValue: {
        type: [String, Number],
        default: "",
      },
      inline: {
        type: Boolean,
        default: false,
      },
      grow: {
        type: Boolean,
        default: false,
      },
      number: {
        type: Boolean,
        default: false,
      },
    },

    template: `
    <div v-bind:class="[inline ? 'inline-field' : 'field', grow ? 'grow' : '']">
      <label v-bind:class="inline ? 'inline-input-label' : 'input-label'">
        {{ label }}
      </label>
      <input
        :value="modelValue"
        @input="$emit('update:data', $event.target.value)"
        v-bind="$attrs"
        v-bind:class="[inputClass, number ? 'input-number' : '']"
      >
    </div>
    `,
  };

  const BaseSwitch = {
    name: "BaseSwitch",

    props: {
      label: {
        type: String,
        default: "",
      },
      modelValue: {
        type: Boolean,
        default: true,
      },
      inline: {
        type: Boolean,
        default: false,
      },
      grow: {
        type: Boolean,
        default: false,
      },
    },

    template: `
    <div v-bind:class="[inline ? 'inline-field' : 'field', grow ? 'grow' : '']">
      <label v-bind:class="inline ? 'inline-input-label' : 'input-label'">
        {{ label }}
      </label>
      <div class="input-container">
        <label class="switch-button">
          <input
            :checked="modelValue"
            type="checkbox"
            @input="$emit('update:modelValue', $event.target.checked)"
            v-bind="$attrs"
            class="switch-button-checkbox"
            v-bind:class="[inputClass, number ? 'input-number' : '']"
          >
          <div class="switch-button-bg" />
        </label>
      </div>
    </div>
    `,
  };

  const ToggleBox = {
    name: "ToggleBox",

    props: {
      toggle: {
        type: Boolean,
        default: true,
      },
    },

    template: `
    <div v-bind:class="toggle ? 'hidden' : ''">
      <slot></slot>
    </div>
    `,
  };

  const app = Vue.createApp({
    components: {
      BaseSelect: BaseSelect,
      BaseInput: BaseInput,
      BaseSwitch: BaseSwitch,
      ToggleBox: ToggleBox,
    },

    template: `
    <div class="app">
      <div>
        <ToggleBox class="info-box" v-bind:toggle="isClientExistent">
          <p>To successfully query, you need at least one GraphQL client available.</p>
          <p>To create a GraphQL client, you can add the <span class="strong">GraphQL client</span> smart cell.</p>
        </ToggleBox>
        <div class="header">
          <div class="inline-field">
            <BaseSelect
              @change="handleClientChange"
              name="client_variable"
              label="Query"
              v-model="payload.client.variable"
              selectClass="input input--xs"
              :existent="isClientExistent"
              :disabled="isClientDisabled"
              :inline
              :options="availableClients"
            />
          </div>
          <div class="inline-field">
            <BaseInput
              @change="handleResultVariableChange"
              name="result_variable"
              label="Assign to"
              type="text"
              placeholder="Assign to"
              v-model="payload.result_variable"
              inputClass="input input--xs input-text"
              :inline
            />
          </div>
          <div class="grow"></div>
          <button id="help-toggle" @click="toggleHelpBox" class="icon-button">
            <i class="ri ri-questionnaire-line" aria-hidden="true"></i>
          </button>
          <button id="settings-toggle" @click="toggleSettingsBox" class="icon-button">
            <i class="ri ri-settings-3-line" aria-hidden="true"></i>
          </button>
      </div>
      <ToggleBox id="help-box" class="section help-box" v-bind:toggle="isHelpBoxHidden">
        <span v-pre>To dynamically inject values into the query use double curly braces, like {{name}}.</span>
      </ToggleBox>
      <ToggleBox id="settings-box" class="section help-box" v-bind:toggle="isSettingsBoxHidden">
        <div class="row mixed-row">
          <BaseInput
            @change="handleTimeoutChange"
            name="timeout"
            label="Timeout"
            type="number"
            v-model="payload.timeout"
            inputClass="input"
          />
          <BaseSwitch
            @change="handleCacheQueryChange"
            name="cache_query"
            label="Cache query"
            v-model="payload.cache_query"
          />
        </div>
      </ToggleBox>
    </div>
    `,

    data() {
      return {
        isHelpBoxHidden: true,
        isSettingsBoxHidden: true,
        isClientExistent: false,
        isClientDisabled: true,
        payload: payload,
        availableDatabases: {
          postgres: "PostgreSQL",
          mysql: "MySQL",
          sqlite: "SQLite",
          bigquery: "Google BigQuery",
          athena: "AWS Athena",
        },
      };
    },

    computed: {
      availableClients() {
        const client = this.payload.client || {
          variable: null,
          type: null
        };
        const clients = this.payload.clients;

        const availableClient = clients.some(
          (conn) => conn.variable === client.variable
        );


        if (this.client === null) {
          this.isClientExistent = false;
          this.isClientDisabled = true;
          return [];
        } else if (this.client != null && this.client.variable == null) {
          this.isClientExistent = false;
          this.isClientDisabled = true;
          return [];
        } else if (availableClient) {
          this.isClientExistent = true;
          this.isClientDisabled = false;
          return this.buildSelectClientOptions(clients);
        } else {
          this.isClientExistent = false;
          this.isClientDisabled = false;
          return this.buildSelectClientOptions([
            client,
            ...clients,
          ]);
        }
      },
    },

    methods: {
      buildSelectClientOptions(clients) {
        return clients.map((conn) => {
          return {
            label: `${conn.variable} (${this.availableDatabases[conn.type]})`,
            value: conn.variable,
          };
        });
      },

      handleResultVariableChange({
        target: {
          value
        }
      }) {
        ctx.pushEvent("update_result_variable", value);
      },

      handleCacheQueryChange({
        target: {
          checked
        }
      }) {
        ctx.pushEvent("update_cache_query", checked);
      },

      handleTimeoutChange({
        target: {
          value
        }
      }) {
        ctx.pushEvent("update_timeout", value);
      },

      handleClientChange({
        target: {
          value
        }
      }) {
        ctx.pushEvent("update_client", value);
      },

      toggleHelpBox(_) {
        this.isHelpBoxHidden = !this.isHelpBoxHidden;
      },

      toggleSettingsBox(_) {
        this.isSettingsBoxHidden = !this.isSettingsBoxHidden;
      },
    },
  }).mount(root);

  ctx.handleEvent("update_result_variable", (variable) => {
    app.payload.result_variable = variable;
  });

  ctx.handleEvent("update_client", (variable) => {
    const client = app.clients.find(
      (conn) => conn.variable === variable
    );
    app.payload.client = client;
  });

  ctx.handleEvent("update_cache_query", (value) => {
    app.payload.cache_query = value;
  });

  ctx.handleEvent("update_timeout", (timeout) => {
    app.payload.timeout = timeout;
  });

  ctx.handleEvent("clients", ({
    clients,
    client
  }) => {
    app.payload.clients = clients;
    app.payload.client = client;
  });

  ctx.handleSync(() => {
    // Synchronously invokes change listeners
    document.activeElement &&
      document.activeElement.dispatchEvent(
        new Event("change", {
          bubbles: true
        })
      );
  });
}