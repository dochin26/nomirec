// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import { Application } from '@hotwired/stimulus'
import { Autocomplete } from 'stimulus-autocomplete'
import "./controllers"
import "./map"

const application = Application.start()
application.register('autocomplete', Autocomplete)