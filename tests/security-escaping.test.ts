import { LuaFactory } from 'wasmoon';
import { OptimizedLuaCompiler } from '../src/mod-logic/optimized-compiler';
import { TweakDefinition } from '../src/mod-logic/tweak-dsl';
import { getMockUnitDefsLua } from './mock-spring';

describe('Security & Escaping Tests', () => {
    let luaFactory: LuaFactory;
    let lua: any;
    let compiler: OptimizedLuaCompiler;

    beforeEach(async () => {
        luaFactory = new LuaFactory();
        lua = await luaFactory.createEngine();
        compiler = new OptimizedLuaCompiler();

        // Setup base environment
        await lua.doString(getMockUnitDefsLua());
        await lua.doString(`
            Spring = {
                GetModOptions = function() return {} end
            }
            if not table then table = {} end
            table.merge = function(t1, t2)
                for k,v in pairs(t2) do t1[k] = v end
                return t1
            end
        `);
    });

    afterEach(() => {
        lua.global.close();
    });

    test('Double quotes inside strings', async () => {
        const tweak: TweakDefinition = {
            name: "Quote Test",
            description: "Test quotes",
            scope: "UnitDefsLoop",
            conditions: [{ type: 'nameMatch', regex: 'armcom' }],
            mutations: [
                { op: 'set', field: 'name', value: 'The "Killer" Unit' }
            ]
        };

        const code = compiler.compile([{ tweak, variables: {} }]);
        await lua.doString(code);

        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armcom.name).toBe('The "Killer" Unit');
    });

    test('Backslashes inside strings', async () => {
        const tweak: TweakDefinition = {
            name: "Backslash Test",
            description: "Test backslashes",
            scope: "UnitDefsLoop",
            conditions: [{ type: 'nameMatch', regex: 'armcom' }],
            mutations: [
                { op: 'set', field: 'name', value: 'C:\\Windows\\System32' }
            ]
        };

        const code = compiler.compile([{ tweak, variables: {} }]);
        await lua.doString(code);

        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armcom.name).toBe('C:\\Windows\\System32');
    });

    test('Newlines inside strings', async () => {
        const multilineText = "Line 1\nLine 2\r\nLine 3";
        const tweak: TweakDefinition = {
            name: "Newline Test",
            description: "Test newlines",
            scope: "UnitDefsLoop",
            conditions: [{ type: 'nameMatch', regex: 'armcom' }],
            mutations: [
                { op: 'set', field: 'description', value: multilineText }
            ]
        };

        const code = compiler.compile([{ tweak, variables: {} }]);
        await lua.doString(code);

        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armcom.description).toBe(multilineText);
    });

    test('Lua comment syntax (--) inside string values', async () => {
        const commentString = "This is not -- a comment";
        const tweak: TweakDefinition = {
            name: "Comment Test",
            description: "Test comments",
            scope: "UnitDefsLoop",
            conditions: [{ type: 'nameMatch', regex: 'armcom' }],
            mutations: [
                { op: 'set', field: 'name', value: commentString }
            ]
        };

        const code = compiler.compile([{ tweak, variables: {} }]);
        await lua.doString(code);

        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armcom.name).toBe(commentString);
    });

    test('Complex injection attempt', async () => {
        // Attempt to close the string and execute code
        const malicious = '"; os.execute("rm -rf /"); local x = "';
        const tweak: TweakDefinition = {
            name: "Injection Test",
            description: "Test injection",
            scope: "UnitDefsLoop",
            conditions: [{ type: 'nameMatch', regex: 'armcom' }],
            mutations: [
                { op: 'set', field: 'name', value: malicious }
            ]
        };

        const code = compiler.compile([{ tweak, variables: {} }]);
        await lua.doString(code);

        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armcom.name).toBe(malicious);
    });
});
