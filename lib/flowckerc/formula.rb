#    Copyright (C) 2015 Leopoldo Lara Vazquez.
#
#    This program is free software: you can redistribute it and/or  modify
#    it under the terms of the GNU Affero General Public License, version 3,
#    as published by the Free Software Foundation.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'hike'

module Flowckerc
  class Formula

    @@trail = Hike::Trail.new "/"
    @@trail.append_extensions ".ff"
    @@trail.append_paths *$:

    def initialize orig_file
      @file = @@trail.find orig_file
      raise 'Cannot find formula '+ orig_file if @file.nil?
    end

    def eval context
      context.instance_eval File.read(@file), @file
    end
  end
end
