#!/usr/bin/env python

## @last-modified 1401-01-03 14:28:05 +0330 Wednesday

from dataclasses import dataclass, field
from json import load as j_load
from os import getenv, path, remove
from pathlib import Path
from sqlite3 import connect

from gp import Color, get_single_input, fzf


@dataclass
class SubCategory:

    columns: str = field(default=None)
    keys: list[str] = field(default_factory=list)
    source_dir: str = field(default=None)
    db_path: str = field(default=None)
    table_name: str = field(default=None)

    row_index: int = 1  ## JUMP_4 don't use enumerate becaues we want to ascend it only if try section finishes successfully

    @property
    def files(self):
        return sorted(Path(self.source_dir).rglob('*.json'))

    @property
    def files_count(self):
        return len(self.files)

    @property
    def marks(self):
        _ = '?,' * len(self.columns.split(','))
        return _.removesuffix(',')


def main():
    print(Col.heading(title))

    main_items = [
        ## fun
        'jeopardy',
        'joke',
        ## history
        'historical-events',
        'history-of-conflicts',
        ## lexicon
        'acronyms',
        'freedictionaryapi',
        'merriam-webster-collegiate-dictionary',
        'merriam-webster-collegiate-thesaurus',
        'wordnet',
        ## news
        'abcnews-headlines',
        'api-news',
        'fake-news',
        ## quote
        'quote-1',
        'quote-2',
    ]
    main_item = fzf(main_items)

    ## confirm to continue
    start_prompt = get_single_input('Start?')
    if not start_prompt == 'y':
        exit()

    ## fun
    if main_item == 'jeopardy':
        SubCat.columns = '''
            funindex INTEGER PRIMARY KEY AUTOINCREMENT,
            question varchar,
            answer   varchar,
            category varchar,
            air_date varchar'''
        SubCat.keys = ['question', 'answer', 'category', 'air_date']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/fun/jeopardy/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/fun/jeopardy/jeopardy.db'
        SubCat.table_name = 'funtable'

    elif main_item == 'joke':
        SubCat.columns = '''
            funindex INTEGER PRIMARY KEY AUTOINCREMENT,
            title    varchar,
            body     varchar,
            category varchar'''
        SubCat.keys = ['title', 'body', 'category']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/fun/joke/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/fun/joke/joke.db'
        SubCat.table_name = 'funtable'

    ## history
    elif main_item == 'historical-events':
        SubCat.columns = '''
            historyindex INTEGER PRIMARY KEY AUTOINCREMENT,
            date         varchar,
            description  varchar,
            category1    varchar,
            category2    varchar,
            granularity  varchar'''
        SubCat.keys = ['date', 'description', 'category1', 'category2', 'granularity']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/history/historical-events/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/history/historical-events/historical-events.db'
        SubCat.table_name = 'historytable'

    elif main_item == 'history-of-conflicts':
        SubCat.columns = '''
            historyindex INTEGER PRIMARY KEY AUTOINCREMENT,
            date         varchar,
            headline     varchar,
            type         varchar,
            country      varchar,
            region       varchar,
            description  varchar,
            sources      varchar'''
        SubCat.keys = ['date', 'headline', 'type', 'country', 'region', 'description', 'sources']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/history/history-of-conflicts/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/history/history-of-conflicts/history-of-conflicts.db'
        SubCat.table_name = 'historytable'

    ## lexicon
    elif main_item == 'acronyms':
        SubCat.columns = '''
            lexiconindex INTEGER PRIMARY KEY AUTOINCREMENT,
            acronym      varchar,
            definition   varchar'''
        SubCat.keys = ['acronym', 'definition']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/lexicon/acronyms/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/lexicon/acronyms/acronyms.db'
        SubCat.table_name = 'lexicontable'

    elif main_item == 'freedictionaryapi':
        SubCat.columns = '''
            lexiconindex INTEGER PRIMARY KEY AUTOINCREMENT,
            word         varchar,
            phonetic     varchar,
            meanings     varchar'''
        SubCat.keys = ['word', 'phonetic', 'meanings']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/lexicon/freedictionaryapi/2-definitions/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/lexicon/freedictionaryapi/freedictionaryapi.db'
        SubCat.table_name = 'lexicontable'

    elif main_item == 'merriam-webster-collegiate-dictionary':
        SubCat.columns = '''
            lexiconindex INTEGER PRIMARY KEY AUTOINCREMENT,
            hw           varchar,
            fl           varchar,
            shortdef     varchar,
            offensive    varchar'''
        SubCat.keys = ['hw', 'fl', 'shortdef', 'offensive']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/lexicon/merriam-webster-collegiate-dictionary/2-definitions/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/lexicon/merriam-webster-collegiate-dictionary/merriam-webster-collegiate-dictionary.db'
        SubCat.table_name = 'lexicontable'

    elif main_item == 'merriam-webster-collegiate-thesaurus':
        SubCat.columns = '''
            lexiconindex INTEGER PRIMARY KEY AUTOINCREMENT,
            hw           varchar,
            fl           varchar,
            syns         varchar,
            ants         varchar,
            shortdef     varchar,
            offensive    varchar'''
        SubCat.keys = ['hw', 'fl', 'syns', 'ants', 'shortdef', 'offensive']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/lexicon/merriam-webster-collegiate-thesaurus/2-synonyms/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/lexicon/merriam-webster-collegiate-thesaurus/merriam-webster-collegiate-thesaurus.db'
        SubCat.table_name = 'lexicontable'

    elif main_item == 'wordnet':
        SubCat.columns = '''
            lexiconindex INTEGER PRIMARY KEY AUTOINCREMENT,
            word         varchar,
            pos          varchar,
            synonyms     varchar'''
        SubCat.keys = ['word', 'pos', 'synonyms']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/lexicon/wordnet/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/lexicon/wordnet/wordnet.db'
        SubCat.table_name = 'lexicontable'

    ## news
    elif main_item == 'abcnews-headlines':
        SubCat.columns = '''
            newsindex INTEGER PRIMARY KEY AUTOINCREMENT,
            date      varchar,
            headline  varchar'''
        SubCat.keys = ['date', 'headline']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/news/abcnews-headlines/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/news/abcnews-headlines/abcnews-headlines.db'
        SubCat.table_name = 'newstable'

    elif main_item == 'api-news':
        SubCat.columns = '''
            newsindex        INTEGER PRIMARY KEY AUTOINCREMENT,
            title            varchar,
            description      varchar,
            full_description varchar,
            content          varchar,
            keywords         varchar,
            category         varchar,
            author           varchar,
            creator          varchar,
            published        varchar,
            publishedAt      varchar,
            pubDate          varchar'''
        SubCat.keys = ['title', 'description', 'full_description', 'content', 'keywords', 'category', 'author', 'creator', 'published', 'publishedAt', 'pubDate']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/news/api-news/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/news/api-news/api-news.db'
        SubCat.table_name = 'newstable'

    elif main_item == 'fake-news':
        SubCat.columns = '''
            newsindex    INTEGER PRIMARY KEY AUTOINCREMENT,
            title        varchar,
            description  varchar,
            date         varchar'''
        SubCat.keys = ['title', 'description', 'date']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/news/fake-news/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/news/fake-news/fake-news.db'
        SubCat.table_name = 'newstable'

    ## quote
    elif main_item == 'quote-1':
        SubCat.columns = '''
            quoteindex INTEGER PRIMARY KEY AUTOINCREMENT,
            by         varchar,
            quote      varchar,
            tags       varchar'''
        SubCat.keys = ['by', 'quote', 'tags']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/quote/quote-1/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/quote/quote-1/quote-1.db'
        SubCat.table_name = 'quotetable'

    elif main_item == 'quote-2':
        SubCat.columns = '''
            quoteindex INTEGER PRIMARY KEY AUTOINCREMENT,
            by         varchar,
            quote      varchar,
            tags       varchar'''
        SubCat.keys = ['by', 'quote', 'tags']
        SubCat.source_dir = f'{getenv("HOME")}/public/github/datasets/quote/quote-2/'
        SubCat.db_path = f'{getenv("HOME")}/website/base/databases/quote/quote-2/quote-2.db'
        SubCat.table_name = 'quotetable'

    print(f'{SubCat.files_count} file(s)\n')

    ## remove db if any
    if path.exists(SubCat.db_path):
        remove(SubCat.db_path)

    ## create table
    with connect(SubCat.db_path) as conn1:
        conn1.execute(f'CREATE TABLE IF NOT EXISTS {SubCat.table_name} ({SubCat.columns});')
        conn1.commit()

    ## iterate over files
    for f in SubCat.files:
        order_in_current_file = 1
        ## NOTE
        ## SubCat.row_index is there to be used in db
        ## while order_in_current_file is there to be shown for each file individually (just to help display proper output in terminal)
        ## using order_in_current_file instead of SubCat.row_index would prevent problem like this
        ## (which happens when there are more than one files in the directory):
        ##
        ##   /home/nnnn/public/github/datasets/news/api-news/currentsapi.json
        ##   5137/5137  <-- [OK for the first file]
        ##   -----------------
        ##   /home/nnnn/public/github/datasets/news/api-news/gnews.json
        ##   5636/499  <-- [must be 499/499]
        ##   -----------------
        ##   /home/nnnn/public/github/datasets/news/api-news/newsapi.json
        ##   11231/5595 <-- [must be 5595/5595]

        print(f)
        with open(f) as opened_f:
            content = j_load(opened_f)
            entries_count = len(content)

        ## iterate over entries
        for entry in content:
            print(f'{order_in_current_file}/{entries_count}', end='\r')

            ## FIXME have to use try because it can't handle it when string contains characters like \n
            try:
                values = [str(entry.get(key, None)) for key in SubCat.keys]
                values.insert(0, SubCat.row_index)

                with connect(SubCat.db_path) as conn2:
                    conn2.execute(f'INSERT INTO {SubCat.table_name} VALUES({SubCat.marks});', values)
                    conn2.commit()

                SubCat.row_index += 1  ## NOTE keep this inside try section for it to ascend only if try finishes successfully
            except Exception as exc:
                print(f'\nERROR: {exc!r}')

            ## no need to keep inside try section because it shows order in the current file and can ascend anyway (unlike SubCat.row_index)
            order_in_current_file += 1

        print('\n') if not f == SubCat.files[-1] else print()


if __name__ == '__main__':
    title = path.basename(__file__).replace('.py', '')
    Col = Color()
    SubCat = SubCategory()
    main()

## soon
