import { createApp, defineComponent } from 'vue';

const App = defineComponent({
  setup() {
    return () => (
      <div>
        <h1>Hello Vue 3 + TypeScript</h1>
        <p>Edit <code>components</code> to get started!</p>
      </div>
    );
  }
});

createApp(App).mount('#app');
