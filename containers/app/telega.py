import json
import logging
from datetime import date

from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

import webbot
from retrieve_secrets import get_secret

logger = logging.getLogger(__name__)


with open('config.json') as f:
    config = json.load(f)
botname = config["botname"]

#Commands

async def start_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if authenticate(update):
        await update.message.reply_text("""Hi, I am a custom bot that gets data from Moje PRE app \n /times to get propper times!""")
    else:
        await update.message.reply_text("""Sadly I don't talk to strangers yet...""")


async def time_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if authenticate(update):
        try:
            time = webbot.main(context.bot_data)
            today = date.today().strftime("%d.%m")
            response = "Cheap electricity is between the hours {} and {}.".format(time[today][0], time[today][1])
        except Exception as e:
            response = "There was an error in retrieving data: {}".format(e)
        await update.message.reply_text(response)
    else:
        await update.message.reply_text("""Sadly I don't talk to strangers yet...""")


async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if authenticate(update):
        await update.message.reply_text("This is a help command")
    else:
        await update.message.reply_text("""Sadly I don't talk to strangers yet...""")

#Logic

def authenticate(update):
    user = update.message.from_user['username']
    if user in config['users']:
        return True
    else:
        return False

def handle_response(text:str, grouptype = 'group') -> str:
    if grouptype == 'group':
        return "Let's speak privately"
    else:
         return "The only useful command is /start or /times"


async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE) :
    #Reply only to allowed users
    if authenticate(update):
        message_type: str = update.message.chat.type
        text: str = update.message.text

        print(f' User ({update.message.chat.id}) in {message_type}: "{text}"')

        if message_type == 'group':
            if botname in text:
                new_text: str = text.replace(botname, '').strip()
                response: str = handle_response(new_text)
            else:
                return
        else:
            response: str = handle_response(text, 'notgroup')

        print('Bot:',response)
        await update.message.reply_text(response)
    else:
        update.message.reply_text("")

async def error(update: Update, context: ContextTypes. DEFAULT_TYPE) :
    print(f'Update {update} caused error {context.error}')


if __name__ == "__main__":
    print("Starting...")
    
    # Retrieving secrets from SecretManager
    creds = get_secret()

    app = Application.builder().token(creds['apikey']).build()

    app.bot_data.update(creds)    

    #Commands
    app.add_handler(CommandHandler('start', start_command))
    app.add_handler(CommandHandler('times', time_command))
    app.add_handler(CommandHandler('help', help_command))

    #Messages
    app.add_handler(MessageHandler(filters. TEXT, handle_message))

    #Errors

    app.add_error_handler(error)

    print('Polling...')
    app.run_polling(poll_interval=3)