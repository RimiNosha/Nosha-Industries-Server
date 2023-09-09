import { useBackend } from '../backend';
import { Section } from '../components';
import { Window } from '../layouts';

type Data = {
  mode: string;
  back_id: string;
  data: SearchData | ListData | EntryData;
};

type BaseData = {
  title: string;
  main_text: string;
};

type SearchData = BaseData & {};

type ListData = BaseData & {};

type EntryData = BaseData & {
  ooc_text: string;
  antag_text: string;
};

export const Codex = (props, context) => {
  const { data } = useBackend<Data>(context);
  return (
    <Window width={370} height={360}>
      <Window.Content scrollable>
        {(data.mode === 'search' && <CodexSearchContent />) ||
          (data.mode === 'list' && <CodexListContent />) ||
          (data.mode === 'search' && <CodexEntryContent />)}
      </Window.Content>
    </Window>
  );
};

export const CodexEntryContent = (props, context) => {
  const { act, data: backendData } = useBackend<Data>(context);
  const { data } = backendData;
  const entryData = data as EntryData;

  return <Section title="Test">Oh yup.</Section>;
};

export const CodexListContent = (props, context) => {
  const { act, data: backendData } = useBackend<Data>(context);
  const { data } = backendData;

  return <Section title="Test">Oh yup.</Section>;
};

export const CodexSearchContent = (props, context) => {
  const { act, data: backendData } = useBackend<Data>(context);
  const { data } = backendData;

  return <Section title="Test">Oh yup.</Section>;
};
