import { classes } from 'common/react';
import { useBackend, useLocalState } from '../../backend';
import { BlockQuote, Box, Button, Divider, Icon, Section, Stack, Tooltip } from '../../components';
import { createSetPreference, Food, Perk, PreferencesMenuData, ServerData, Species } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

const FOOD_ICONS = {
  [Food.Bugs]: 'bug',
  [Food.Cloth]: 'tshirt',
  [Food.Dairy]: 'cheese',
  [Food.Fried]: 'bacon',
  [Food.Fruit]: 'apple-alt',
  [Food.Gore]: 'skull',
  [Food.Grain]: 'bread-slice',
  [Food.Gross]: 'trash',
  [Food.Junkfood]: 'pizza-slice',
  [Food.Meat]: 'hamburger',
  [Food.Nuts]: 'seedling',
  [Food.Raw]: 'drumstick-bite',
  [Food.Seafood]: 'fish',
  [Food.Sugar]: 'candy-cane',
  [Food.Toxic]: 'biohazard',
  [Food.Vegetables]: 'carrot',
  [Food.Electricity]: 'bolt-lightning',
};

const FOOD_NAMES: Record<keyof typeof FOOD_ICONS, string> = {
  [Food.Bugs]: 'Bugs',
  [Food.Cloth]: 'Clothing',
  [Food.Dairy]: 'Dairy',
  [Food.Fried]: 'Fried food',
  [Food.Fruit]: 'Fruit',
  [Food.Gore]: 'Gore',
  [Food.Grain]: 'Grain',
  [Food.Gross]: 'Gross food',
  [Food.Junkfood]: 'Junk food',
  [Food.Meat]: 'Meat',
  [Food.Nuts]: 'Nuts',
  [Food.Raw]: 'Raw',
  [Food.Seafood]: 'Seafood',
  [Food.Sugar]: 'Sugar',
  [Food.Toxic]: 'Toxic food',
  [Food.Vegetables]: 'Vegetables',
  [Food.Electricity]: 'Electricity',
};

const IGNORE_UNLESS_LIKED: Set<Food> = new Set([
  Food.Bugs,
  Food.Cloth,
  Food.Gross,
  Food.Toxic,
]);

const notIn = function <T>(set: Set<T>) {
  return (value: T) => {
    return !set.has(value);
  };
};

const FoodList = (props: {
  food: Food[];
  icon: string;
  name: string;
  className: string;
}) => {
  if (props.food.length === 0) {
    return null;
  }

  return (
    <Tooltip
      position="bottom-end"
      content={
        <Box>
          <Icon name={props.icon} /> <b>{props.name}</b>
          <Divider />
          <Box>
            {props.food
              .reduce((names, food) => {
                const foodName = FOOD_NAMES[food];
                return foodName ? names.concat(foodName) : names;
              }, [])
              .join(', ')}
          </Box>
        </Box>
      }>
      <Stack ml={2}>
        {props.food.map((food) => {
          return (
            FOOD_ICONS[food] && (
              <Stack.Item>
                <Icon
                  className={props.className}
                  size={1.4}
                  key={food}
                  name={FOOD_ICONS[food]}
                />
              </Stack.Item>
            )
          );
        })}
      </Stack>
    </Tooltip>
  );
};

const Diet = (props: { diet: Species['diet'] }) => {
  if (!props.diet) {
    return null;
  }

  const { liked_food, disliked_food, toxic_food } = props.diet;

  return (
    <Stack>
      <Stack.Item>
        <FoodList
          food={liked_food}
          icon="heart"
          name="Liked food"
          className="color-pink"
        />
      </Stack.Item>

      <Stack.Item>
        <FoodList
          food={disliked_food.filter(notIn(IGNORE_UNLESS_LIKED))}
          icon="thumbs-down"
          name="Disliked food"
          className="color-red"
        />
      </Stack.Item>

      <Stack.Item>
        <FoodList
          food={toxic_food.filter(notIn(IGNORE_UNLESS_LIKED))}
          icon="biohazard"
          name="Toxic food"
          className="color-olive"
        />
      </Stack.Item>
    </Stack>
  );
};

const SpeciesPerk = (props: { className: string; perk: Perk }) => {
  const { className, perk } = props;

  return (
    <Tooltip
      position="bottom-end"
      content={
        <Box>
          <Box as="b">{perk.name}</Box>
          <Divider />
          <Box>{perk.description}</Box>
        </Box>
      }>
      <Box class={className} width="32px" height="32px">
        <Icon
          name={perk.ui_icon}
          size={1.5}
          mt={1}
          style={{
            color: 'black',
            'text-align': 'center',
            height: '100%',
            width: '100%',
          }}
        />
      </Box>
    </Tooltip>
  );
};

const SpeciesPerks = (props: { perks: Species['perks'] }) => {
  const { positive, negative, neutral } = props.perks;

  return (
    <Stack fill justify="flex-end">
      <Stack.Item>
        <Stack>
          {positive.map((perk) => {
            return (
              <Stack.Item key={perk.name}>
                <SpeciesPerk className="color-bg-green" perk={perk} />
              </Stack.Item>
            );
          })}
        </Stack>
      </Stack.Item>

      {!!positive?.length && !!neutral?.length && <Stack.Divider mr="0.5rem" />}

      <Stack grow>
        {neutral.map((perk) => {
          return (
            <Stack.Item key={perk.name}>
              <SpeciesPerk className="color-bg-grey" perk={perk} />
            </Stack.Item>
          );
        })}
      </Stack>

      {!!neutral?.length && !!negative?.length && <Stack.Divider mr="0.5rem" />}

      {!!positive.length && !neutral?.length && !!negative?.length && (
        <Stack.Divider mr="0.5rem" />
      )}

      <Stack>
        {negative.map((perk) => {
          return (
            <Stack.Item key={perk.name}>
              <SpeciesPerk className="color-bg-red" perk={perk} />
            </Stack.Item>
          );
        })}
      </Stack>
    </Stack>
  );
};

const SpeciesPageInner = (
  props: {
    species: ServerData['species'];
  },
  context
) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const setSpecies = createSetPreference(act, 'species');

  let species: [string, Species][] = Object.entries(props.species).map(
    ([species, data]) => {
      return [species, data];
    }
  );

  // Humans are always the top of the list
  const humanIndex = species.findIndex(([species]) => species === 'human');
  const swapWith = species[0];
  species[0] = species[humanIndex];
  species[humanIndex] = swapWith;

  const [previewedSpecies, setPreviewedSpecies] = useLocalState(
    context,
    'previewedSpecies',
    data.character_preferences.misc.species
  );

  const [selectedBaseSpecies, setSelectedBaseSpecies] = useLocalState(
    context,
    'selectedBaseSpecies',
    species
      .filter(([speciesKey, speciesData]) => {
        return (
          speciesKey === data.character_preferences.misc.species ||
          speciesData.parent_species === data.character_preferences.misc.species
        );
      })
      .map(([key]) => {
        return key;
      })[0]
  );

  const currentSpeciesEntry = species.filter(([speciesKey]) => {
    return speciesKey === previewedSpecies;
  })[0];
  const currentSpecies = currentSpeciesEntry[1];

  return (
    <Stack vertical fill>
      <Stack.Item justify="center" align="center" fontSize="1.2em">
        <Button
          icon="check"
          onClick={() => setSpecies(previewedSpecies)}
          content="Apply Species"
          style={{ 'padding': '5px' }}
        />
      </Stack.Item>

      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item>
            <Box width="100%" overflowX="auto" pr="3px">
              {species.map(([speciesKey, speciesData]) => {
                if (speciesData.parent_species) {
                  return null;
                }
                return (
                  <Button
                    key={speciesKey}
                    onClick={() => {
                      setPreviewedSpecies(speciesKey);
                      setSelectedBaseSpecies(
                        speciesData.parent_species || speciesKey
                      );
                    }}
                    selected={selectedBaseSpecies === speciesKey}
                    content={speciesData.name}
                    style={{
                      display: 'inline-block',
                    }}
                  />
                );
              })}
            </Box>
          </Stack.Item>

          <Stack.Item>
            <Box width="100%" overflowX="auto" pr="3px">
              {species.map(([speciesKey, speciesData]) => {
                if (
                  speciesData.parent_species === currentSpeciesEntry[0] ||
                  speciesKey === currentSpeciesEntry[0] ||
                  speciesKey === currentSpecies.parent_species ||
                  (speciesData.parent_species &&
                    speciesData.parent_species ===
                      currentSpecies.parent_species)
                ) {
                  return (
                    <Button
                      key={speciesKey}
                      onClick={() => {
                        setPreviewedSpecies(speciesKey);
                      }}
                      selected={
                        data.character_preferences.misc.species === speciesKey
                      }
                      tooltip={speciesData.name}
                      style={
                        currentSpeciesEntry[0] === speciesKey
                          ? {
                            'background-color': 'skyblue',
                            display: 'inline-block',
                            height: '66px',
                            width: '66px',
                          }
                          : {
                            display: 'inline-block',
                            height: '66px',
                            width: '66px',
                          }
                      }>
                      <Box
                        className={classes(['species64x64', speciesData.icon])}
                        ml={-1}
                      />
                    </Button>
                  );
                }
              })}
            </Box>
          </Stack.Item>

          <Stack.Item grow>
            <Box fill>
              <Box>
                <Stack fill>
                  <Stack.Item width="100%">
                    <Section
                      title={currentSpecies.name}
                      buttons={
                        // NOHUNGER species have no diet (diet = null),
                        // so we have nothing to show
                        currentSpecies.diet && (
                          <Diet diet={currentSpecies.diet} />
                        )
                      }>
                      <Section title="Description">
                        {currentSpecies.desc}
                      </Section>

                      <Section title="Features">
                        <SpeciesPerks perks={currentSpecies.perks} />
                      </Section>
                    </Section>
                  </Stack.Item>
                </Stack>
              </Box>

              <Box mt={1}>
                <Section title="Lore">
                  <BlockQuote>
                    {currentSpecies.lore.map((text, index) => (
                      <Box key={index} width="100%">
                        {text}
                        {index !== currentSpecies.lore.length - 1 && (
                          <>
                            <br />
                            <br />
                          </>
                        )}
                      </Box>
                    ))}
                  </BlockQuote>
                </Section>
              </Box>
            </Box>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const SpeciesPage = () => {
  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (serverData) {
          return <SpeciesPageInner species={serverData.species} />;
        } else {
          return <Box>Loading species...</Box>;
        }
      }}
    />
  );
};
