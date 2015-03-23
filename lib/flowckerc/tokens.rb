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

module Flowckerc
  class Link
    attr_reader :id
    attr_accessor :from_atom
    attr_accessor :from_port
    attr_accessor :to_atom
    attr_accessor :to_port

    def initialize from_atom, from_port, to_atom, to_port
      @id = UniqueID.next
      @from_atom = from_atom
      @from_port = from_port
      @to_atom = to_atom
      @to_port = to_port
    end

    def toHash
      {
          id: @id,
          from: {
            atomID: @from_atom,
            port: {
              name: @from_port
            }
          },
          to: {
            atomID: @to_atom,
            port: {
              name: @to_port
            }
          }
      }
    end
  end

  class Atom
    attr_reader :id
    attr_reader :element
    attr_accessor :config

    def initialize element
      @id = UniqueID.next
      @element = element
      @config = {}
    end

    def toHash
      {
          id: @id,
          element: @element,
          config: @config
      }
    end
  end

  class Molecule
    attr_accessor :atoms
    attr_accessor :links

    def initialize
      @atoms = []
      @links = []
    end

    def toHash
      res = {}
      res[:atoms] = @atoms.map do |atom|
        atom.toHash
      end

      res[:links] = @links.map do |link|
        link.toHash
      end
      res
    end
  end

  class MoleculePorts
    attr_accessor :inports
    attr_accessor :outports

    def initialize
      @inports = []
      @outports = []
    end

    def inportByName name
      @inports.each do |port|
        return port if port[:name] == name
      end
      return nil
    end

    def outportByName name
      @outports.each do |port|
        return port if port[:name] == name
      end
      return nil
    end
  end

  class FormulaSolution
    attr_accessor :molecule
    attr_accessor :molecule_ports

    def initialize molecule, molecule_ports
      @molecule = molecule
      @molecule_ports = molecule_ports
    end
  end


end
