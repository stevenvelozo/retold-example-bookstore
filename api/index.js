/*
	An example of Meadow Endpoints, Fable and Orator
*/
/**
* @license MIT
* @author <steven@velozo.com>
*/
// Server Settings
const _Settings = require('./bookstore-configuration.json');
// Fable is logging and settings
const libFable = require('fable');
// Orator is the web server
const libOrator = require('orator');
// Official MySQL Client
const libMySQL = require('mysql2');
// Meadow is the DAL
const libMeadow = require('meadow');
// Meadow-endpoints maps the DAL to restify endpoints automagically
const libMeadowEndpoints = require('meadow-endpoints');

let _Fable = libFable.new(_Settings);
let _Orator = libOrator.new(_Settings);
let _Meadow = libMeadow.new(_Fable);

_Fable.log.info("Application is starting up...");

_Fable.log.info("...Creating Mock User Session and adding it to all requests on Restify/Orator");
var _MockSessionValidUser = require('./bookstore-usersession.json');
var fMockAuthentication = (pRequest, pResponse, fNext) =>
{
	pRequest.UserSession = _MockSessionValidUser;
	fNext();
};
_Orator.webServer.use(fMockAuthentication);

_Fable.log.info("...Creating SQL Connection pools at "+_Fable.settings.MySQL.Server+"...");
// Setup SQL Connection Pool
_Fable.MeadowMySQLConnectionPool = libMySQL.createPool
	(
		{
			connectionLimit: _Fable.settings.MySQL.ConnectionPoolLimit,
			host: _Fable.settings.MySQL.Server,
			port: _Fable.settings.MySQL.Port,
			user: _Fable.settings.MySQL.User,
			password: _Fable.settings.MySQL.Password,
			database: _Fable.settings.MySQL.Database,
			namedPlaceholders: true
		}
	);

// Create DAL objects for each table in the schema
let _DAL = {};
let _MeadowEndpoints = {};
// 1. Load full compiled schema of the model from stricture
const _BookStoreModel = require (__dirname+'/model/json_schema/BookStore-Extended.json');
// 2. Extract an array of each table in the schema
const _BookStoreTableList = Object.keys(_BookStoreModel.Tables);
// 3. Enumerate each entry in the compiled model and load a DAL for that table
_Fable.log.info(`...Creating ${_BookStoreTableList.length} DAL entries...`);
for (let i = 0; i < _BookStoreTableList.length; i++)
{
	let tmpDALEntityName = _BookStoreTableList[i];
	_Fable.log.info(`   -> Creating the ${tmpDALEntityName} DAL...`);
	// 4. Create the DAL for each entry (e.g. it would be at _DAL.Book or _DAL.Author)
	_DAL[tmpDALEntityName] = _Meadow.loadFromPackage(__dirname+'/model/meadow_schema/BookStore-MeadowSchema-'+tmpDALEntityName+'.json');
	// 5. Tell this DAL object to use MySQL
	_DAL[tmpDALEntityName].setProvider('MySQL');
	// 6. Set the User ID to 10 just for fun
	_DAL[tmpDALEntityName].setIDUser(1);
	// 7. Create a Meadow Endpoints class for this DAL
	_MeadowEndpoints[tmpDALEntityName] = libMeadowEndpoints.new(_DAL[tmpDALEntityName]);
	// 8. Expose the meadow endpoints on Orator
	_MeadowEndpoints[tmpDALEntityName].connectRoutes(_Orator.webServer);
}

// 100. Add a post processing hook to the Book DAL on single reads
/*
	This post processing step will look for all book author joins then 
	load all appropriate authors and stuff them in the book record before 
	returning it.
*/
_MeadowEndpoints.Book.behaviorModifications.setBehavior('Read-PostOperation',
	(pRequest, fComplete) =>
	{
		// Get the join records
		_DAL.BookAuthorJoin.doReads(_DAL.BookAuthorJoin.query.addFilter('IDBook', pRequest.Record.IDBook),
			(pJoinReadError, pJoinReadQuery, pJoinRecords)=>
			{
				let tmpAuthorList = [];
				for (let j = 0; j < pJoinRecords.length; j++)
				{
					tmpAuthorList.push(pJoinRecords[j].IDAuthor);
				}
				_DAL.Author.doReads(_DAL.Author.query.addFilter('IDAuthor', tmpAuthorList, 'IN'),
					(pReadsError, pReadsQuery, pAuthors)=>
					{
						pRequest.Record.Authors = pAuthors;
						fComplete(false);
					});
			});
	});

// Static site mapping
_Orator.log.info("...Mapping static route for web site...");
_Orator.addStaticRoute(__dirname+'/../web/');

// Start the web server (ctrl+c to end it)
_Orator.startWebServer();