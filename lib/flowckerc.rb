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

require 'flowckerc/version'
require 'flowckerc/tokens'
require 'flowckerc/formula'

module Flowckerc
  module UniqueID
    @@count = 0

    def self.next
      @@count = @@count + 1
      @@count
    end
  end

  class SymTable
    def initialize
      @table = {}
    end

    def add sym, value
      @table[sym] = value
    end

    def getId sym
      @table[sym].id
    end

    def value sym
      @table[sym]
    end

    def isAtom sym
      @table[sym].is_a? Atom
    end

    def isSolution
      @table[sym].is_a? FormulaSolution
    end
  end

  class SolverClass
    def solve formula, options={}
      syms = SymTable.new
      molecule = Molecule.new
      molecule_ports = MoleculePorts.new

      context = FormulaExecContext.new syms, molecule, molecule_ports, options
      formula.eval context

      LinksSolver.new(syms).solve(molecule.links)

      solve_ports_ids syms, molecule_ports

      FormulaSolution.new molecule, molecule_ports
    end

    private

    def solve_ports_ids syms, molecule_ports
      molecule_ports.inports.each do |inport|
        if inport[:to_atom].is_a? Symbol
          inport[:to_atom] = syms.getId inport[:to_atom]
        end
      end

      molecule_ports.outports.each do |outport|
        if outport[:from_atom].is_a? Symbol
          outport[:from_atom] = syms.getId outport[:from_atom]
        end
      end
    end

    class LinksSolver
      def initialize syms
        @syms = syms
      end

      def solve links
        links.each do |link|
          if link.from_atom.is_a? Symbol
            solve_src link
          end
          if link.to_atom.is_a? Symbol
            solve_dst link
          end
        end
      end

      def solve_src link
        name = link.from_atom
        port = link.from_port
        if @syms.isAtom name
          link.from_atom = @syms.getId name
        else
          solution = @syms.value name
          actual_port =  solution.molecule_ports.outportByName port
          link.from_atom = actual_port[:from_atom]
          link.from_port = actual_port[:from_port]
        end
      end

      def solve_dst link
        name = link.to_atom
        port = link.to_port
        if @syms.isAtom name
          link.to_atom = @syms.getId name
        else
          solution = @syms.value name
          actual_port =  solution.molecule_ports.inportByName port
          link.to_atom = actual_port[:to_atom]
          link.to_port = actual_port[:to_port]
        end
      end
    end

    class AtomExecContext
      def initialize atom, parent
        @atom = atom
        @parent = parent
      end

      def out spec
        from_port = spec[:from]
        spec[:from] = [@atom.id, from_port]
        @parent.link spec
      end

      def inp spec
        to_port = spec[:to]
        spec[:to] = [@atom.id, to_port]
        @parent.link spec
      end

      def name atom_name
        @parent.syms.add atom_name, @atom
      end

      def config data={}
        @atom.config = data
      end

      def options
        @parent.options
      end
    end

    class FormulaExecContext
      attr_reader :syms
      attr_reader :options
      def initialize syms, molecule, molecule_ports, options
        @syms = syms
        @molecule = molecule
        @molecule_ports = molecule_ports
        @options = options
      end

      def atom element, &blk
        atom = Atom.new element
        @molecule.atoms.push atom
        AtomExecContext.new(atom, self).instance_exec &blk
      end

      def link spec={}
        @molecule.links.push Link.new spec[:from][0], spec[:from][1], spec[:to][0], spec[:to][1]
      end

      def inport name, to_atom, to_port
        @molecule_ports.inports.push  name: name,
                                      to_atom: to_atom,
                                      to_port: to_port
      end

      def outport name, from_atom, from_port
        @molecule_ports.outports.push   name: name,
                                        from_atom: from_atom,
                                        from_port: from_port
      end

      def mix formula_file, name, options={}
        formula = Formula.new formula_file
        solution = Solver.solve formula, options
        @molecule.atoms += solution.molecule.atoms
        @molecule.links += solution.molecule.links

        @syms.add name, solution
      end
    end
  end

  Solver = SolverClass.new

end
