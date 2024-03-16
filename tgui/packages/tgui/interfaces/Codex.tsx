import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';
import '../styles/interfaces/Codex.scss';

/**
 * This is an entirely safe string to element replacer, provided you don't do anything hacky or stupid.
 * @param stringToCheck The string to pick through. Will be returned unchanged if the regex picks up on nothing.
 * @param regex The regex to check the string with. Capture groups `()` are supported. @see RegExp.
 * @param formattingFunction The function to format with. Index 0 of the input is the full string to be formatted, and indexes after 0 are your capture groups.
 * @returns An array containing the replacement formatted by formattingFunction.
 */
const replaceStringWithElements = (
  stringToCheck: string,
  regex: RegExp,
  formattingFunction: (matches: string[]) => any
): any[] => {
  let result: any[] = [];
  const nonCapturingRegex =
    '(' + regex.source.replace(new RegExp('(?!\\\\)\\(', 'g'), '(?:') + ')';
  const stringsToCheck = stringToCheck.split(new RegExp(nonCapturingRegex));
  if (stringsToCheck.constructor !== Array) {
    result.push(stringToCheck);
    return result;
  }
  stringsToCheck.forEach((entry) => {
    let matches = regex.exec(entry);
    if (matches) {
      result.push(formattingFunction(matches));
    } else {
      result.push(entry);
    }
  });
  if (!result.length) {
    result.push(stringToCheck);
  }

  return result;
};

const linkRegex = new RegExp(
  "<(span|l)(\\s+codexlink='([^>]*)'|)>([^<]+)<\\/(span|l)>",
  'gi'
);

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
  lore_text: string;
  control_text: string;
  antag_text: string;
};

export const Codex = (props, context) => {
  const { data } = useBackend<Data>(context);
  return (
    <Window width={500} height={500} title="Codex">
      <Window.Content scrollable>
        <CodexEntryContent />
        {(data.mode === 'search' && <CodexSearchContent />) ||
          (data.mode === 'list' && <CodexListContent />) ||
          (data.mode === 'entry' && <CodexEntryContent />)}
      </Window.Content>
    </Window>
  );
};

const CodexEntryContent = (props, context) => {
  const { act, data: backendData } = useBackend<Data>(context);
  const { data } = backendData;
  const entryData = data as EntryData;

  return (
    <Section
      title={entryData.title}
      buttons={
        <>
          <Button
            icon="list"
            onClick={() => act('open', { 'page': 'Categories (category)' })}>
            Index
          </Button>
          <Button
            icon="house"
            onClick={() => act('open', { 'page': 'The Codex' })}>
            Home
          </Button>
        </>
      }>
      <CodexEntrySection name="OOC Info" text={entryData.main_text} act={act} />
      <CodexEntrySection
        name="Lore Info"
        text={entryData.lore_text}
        act={act}
      />
      <CodexEntrySection
        name="Controls Info"
        text={entryData.control_text}
        act={act}
      />
      <CodexEntrySection
        name="Antag Info"
        text={entryData.antag_text}
        act={act}
      />
    </Section>
  );
};

const insertFiller = (arr, filler) =>
  arr.flatMap((n) => [n, filler]).slice(0, -1);

const CodexEntrySection = (props, context) => {
  const { name, text, act } = props;
  if (!text) {
    return null;
  }

  return (
    <Section title={name}>
      <div
        style={{ 'white-space': 'pre-wrap' }}
        // This is data given directly by the server, which can only be set by admins with VV, and I'm *not* making a whole ass html baby-fier.
        // eslint-disable-next-line react/no-danger
        dangerouslySetInnerHTML={{
          // Oh my god this is so awful
          __html: Object.entries(text)
            .map((entry) =>
              replaceStringWithElements(
                entry[1] as string,
                linkRegex,
                (foundText) => (
                  <a
                    onClick={() =>
                      act('open', { 'page': foundText[3] || foundText[4] })
                    }>
                    {foundText[4]}
                  </a>
                )
              ).join('')
            )
            .join(''),
        }}
      />
    </Section>
  );
};

const CodexListContent = (props, context) => {
  const { act, data: backendData } = useBackend<Data>(context);
  const { data } = backendData;

  return <Section title="Test">Oh yup.</Section>;
};

const CodexSearchContent = (props, context) => {
  const { act, data: backendData } = useBackend<Data>(context);
  const { data } = backendData;

  return <Section title="Test">Oh yup.</Section>;
};
