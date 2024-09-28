import React, { useCallback, useEffect, useState } from 'react';

import useAxios from 'axios-hooks';
import { useParams } from 'react-router-dom';
import { v4 as uuidv4 } from 'uuid';

interface LifeLocation {
  x: number;
  y: number;
}

interface Iteration {
  is_final: boolean;
  life_locations: LifeLocation[];
}

interface Cursor {
  uuid?: string;
  offset?: number;
}

interface IterationResponse {
  iteration: Iteration;
  cursor: Cursor;
}

interface BoardResponse {
  board: {
    height: number;
    width: number;
    status: string;
  };
}

function Board() {
  const { boardId } = useParams();

  const [cursor, setCursor] = useState<Cursor>({ uuid: uuidv4() });
  const [lifeLocationsSet, setLifeLocationsSet] = useState<Set<string>>(
    new Set()
  );

  const [{ data: boardData, loading: boardLoading, error: boardError }] =
    useAxios<BoardResponse>(`/boards/${boardId}`);

  const [, sendGetNext] = useAxios<IterationResponse>(
    {
      url: '/iterations/next',
      method: 'get',
      params: {
        board_id: boardId,
        cursor: cursor
      }
    },
    { manual: true }
  );

  const executeGetNext = async () => {
    const { data } = await sendGetNext();
    setCursor(data.cursor);
    setLifeLocationsSet(
      new Set(data.iteration.life_locations.map(l => `${l.y}/${l.x}`))
    );
  };

  const executeGetNextOnMount = useCallback(async () => {
    await executeGetNext();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    executeGetNextOnMount().catch(console.error);
  }, [executeGetNextOnMount]);

  if (boardLoading) return <p>Loading...</p>;
  if (boardError) return <p>Error!</p>;

  return (
    <>
      <div className="bg-blue-300 p-4 text-white">
        <h1 className="mb-4 text-2xl font-extrabold leading-none tracking-tight text-neutral-950 md:text-5xl lg:text-4xl">
          Board #{boardId} ({boardData?.board?.height}x{boardData?.board?.width}
          )
          <span className="bg-blue-100 text-blue-800 text-2xl font-semibold me-2 px-2.5 py-0.5 rounded dark:bg-blue-200 dark:text-blue-800 ms-2">
            {boardData?.board?.status?.toUpperCase()}
          </span>
        </h1>
      </div>
      {cursor.offset && lifeLocationsSet.size > 0 && (
        <table className="table-auto m-4 w-screen">
          <tbody>
            {Array.from({ length: boardData!.board.height }, (_, y) => (
              <tr key={y}>
                {Array.from({ length: boardData!.board.width }, (_, x) => (
                  <td
                    key={`${y}/${x}`}
                    className={`${lifeLocationsSet.has(`${y}/${x}`) && 'bg-black'} h-3`}></td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      )}
      <div className="flex items-center w-full max-w-md m-6 seva-fields formkit-fields">
        <button onClick={executeGetNext}>
          <span className="px-5 py-3 text-sm font-medium text-center text-white bg-blue-700 rounded-lg cursor-pointer hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">
            Next iteration
          </span>
        </button>
      </div>
    </>
  );
}

export default Board;
